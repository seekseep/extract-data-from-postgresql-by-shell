#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# 引数チェック
if [ $# -ne 2 ]; then
  echo "使い方: $0 <開始日> <終了日>"
  echo "例: $0 2024-01-01 2024-12-31"
  exit 1
fi

START_DATE="$1"
END_DATE="$2"

# .env ファイルを読み込む
if [ -f "$PROJECT_ROOT/.env" ]; then
  export $(grep -v '^#' "$PROJECT_ROOT/.env" | xargs)
fi

# 環境変数のチェック
: "${POSTGRES_USER:?POSTGRES_USER is required}"
: "${POSTGRES_PASSWORD:?POSTGRES_PASSWORD is required}"
: "${POSTGRES_DB:?POSTGRES_DB is required}"
: "${POSTGRES_PORT:=5432}"
: "${POSTGRES_HOST:=localhost}"

# 出力ファイル
OUTPUT_FILE="$PROJECT_ROOT/output/sales_pivot_plpgsql_${START_DATE}_${END_DATE}.csv"

# 出力ディレクトリ作成
mkdir -p "$PROJECT_ROOT/output"

# PL/pgSQLで動的ピボットテーブルを作成するSQL
# 引数は一時テーブル経由で渡す
SQL=$(cat <<EOF
-- 引数を一時テーブルに保存
CREATE TEMP TABLE params AS
SELECT '${START_DATE}'::DATE AS start_date, '${END_DATE}'::DATE AS end_date;

DO \$\$
DECLARE
  sum_columns TEXT := '';
  pivot_query TEXT;
  rec RECORD;
  v_start_date DATE;
  v_end_date DATE;
BEGIN
  -- 引数を取得
  SELECT
    DATE_TRUNC('month', start_date)::DATE,
    DATE_TRUNC('month', end_date)::DATE
  INTO v_start_date, v_end_date
  FROM params;

  -- generate_series で期間内のすべての月を生成してカラム定義を生成
  FOR rec IN
    SELECT TO_CHAR(month_date, 'YYYY-MM') AS month
    FROM generate_series(v_start_date, v_end_date, INTERVAL '1 month') AS month_date
    ORDER BY month_date
  LOOP
    -- format() を使用して安全に動的SQLを構築
    sum_columns := sum_columns || format(
      ', COALESCE(SUM(CASE WHEN month = %L THEN sales ELSE 0 END), 0) AS %I',
      rec.month, rec.month
    );
  END LOOP;

  -- 動的SQLでピボットテーブルを作成
  pivot_query := '
    CREATE TEMP TABLE pivot_result AS
    WITH sales_data AS (
      SELECT
        c.company_id,
        c.name AS company_name,
        TO_CHAR(o.ordered_at, ''YYYY-MM'') AS month,
        COALESCE(SUM(oi.quantity * oi.unit_price), 0) AS sales
      FROM orders o
      JOIN departments d ON o.department_id = d.department_id
      JOIN companies c ON d.company_id = c.company_id
      LEFT JOIN order_items oi ON o.order_id = oi.order_id
      WHERE o.ordered_at >= (SELECT start_date FROM params)
        AND o.ordered_at < (SELECT end_date FROM params) + INTERVAL ''1 month''
      GROUP BY c.company_id, c.name, TO_CHAR(o.ordered_at, ''YYYY-MM'')
    )
    SELECT
      company_name AS "会社名"' || sum_columns || '
    FROM sales_data
    GROUP BY company_id, company_name
    ORDER BY company_name
  ';

  EXECUTE pivot_query;
END \$\$;

-- 結果をCSV形式で出力
COPY pivot_result TO STDOUT WITH CSV HEADER;

-- 一時テーブルを削除
DROP TABLE IF EXISTS pivot_result;
DROP TABLE IF EXISTS params;
EOF
)

# SQL実行してCSV出力（-q で余計な出力を抑制）
echo "$SQL" | PGPASSWORD="$POSTGRES_PASSWORD" psql \
  -q \
  -h "$POSTGRES_HOST" \
  -p "$POSTGRES_PORT" \
  -U "$POSTGRES_USER" \
  -d "$POSTGRES_DB" > "$OUTPUT_FILE"

echo "CSVファイルを出力しました: $OUTPUT_FILE"
