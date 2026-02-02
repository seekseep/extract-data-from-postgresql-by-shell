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
OUTPUT_FILE="$PROJECT_ROOT/output/sales_by_company_and_month_${START_DATE}_${END_DATE}.csv"

# 出力ディレクトリ作成
mkdir -p "$PROJECT_ROOT/output"

# 会社名と月ごとの売上金額を集計するSQL
SQL="
COPY (
  SELECT
    TO_CHAR(o.ordered_at, 'YYYY-MM') AS 月,
    c.name AS 会社名,
    COALESCE(SUM(oi.quantity * oi.unit_price), 0) AS 売上金額
  FROM orders o
  JOIN departments d ON o.department_id = d.department_id
  JOIN companies c ON d.company_id = c.company_id
  LEFT JOIN order_items oi ON o.order_id = oi.order_id
  WHERE o.ordered_at >= :'start_date'::DATE
    AND o.ordered_at < :'end_date'::DATE + INTERVAL '1 month'
  GROUP BY TO_CHAR(o.ordered_at, 'YYYY-MM'), c.name
  ORDER BY 月, 会社名
) TO STDOUT WITH CSV HEADER
"

# SQL実行してCSV出力
echo "$SQL" | PGPASSWORD="$POSTGRES_PASSWORD" psql \
  -h "$POSTGRES_HOST" \
  -p "$POSTGRES_PORT" \
  -U "$POSTGRES_USER" \
  -d "$POSTGRES_DB" \
  -v start_date="$START_DATE" \
  -v end_date="$END_DATE" > "$OUTPUT_FILE"

echo "CSVファイルを出力しました: $OUTPUT_FILE"
