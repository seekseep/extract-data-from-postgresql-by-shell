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
OUTPUT_FILE="$PROJECT_ROOT/output/sales_pivot_awk_${START_DATE}_${END_DATE}.csv"

# 出力ディレクトリ作成
mkdir -p "$PROJECT_ROOT/output"

# 会社名と月ごとの売上金額を集計するSQL
SQL="
COPY (
  SELECT
    TO_CHAR(o.ordered_at, 'YYYY-MM') AS month,
    c.name AS company_name,
    COALESCE(SUM(oi.quantity * oi.unit_price), 0) AS sales
  FROM orders o
  JOIN departments d ON o.department_id = d.department_id
  JOIN companies c ON d.company_id = c.company_id
  LEFT JOIN order_items oi ON o.order_id = oi.order_id
  WHERE o.ordered_at >= :'start_date'::DATE
    AND o.ordered_at < :'end_date'::DATE + INTERVAL '1 month'
  GROUP BY TO_CHAR(o.ordered_at, 'YYYY-MM'), c.name
  ORDER BY month, company_name
) TO STDOUT WITH CSV HEADER
"

# SQLを実行してデータを取得（一時ファイルに保存）
TEMP_FILE=$(mktemp)
trap "rm -f $TEMP_FILE" EXIT

echo "$SQL" | PGPASSWORD="$POSTGRES_PASSWORD" psql \
  -h "$POSTGRES_HOST" \
  -p "$POSTGRES_PORT" \
  -U "$POSTGRES_USER" \
  -d "$POSTGRES_DB" \
  -v start_date="$START_DATE" \
  -v end_date="$END_DATE" > "$TEMP_FILE"

# シェルスクリプト(awk)でピボットテーブルに変換
awk -F',' -v start_date="$START_DATE" -v end_date="$END_DATE" '
BEGIN {
  OFS = ","

  # 開始日と終了日から年月を抽出
  split(start_date, s, "-")
  split(end_date, e, "-")
  start_year = int(s[1])
  start_month = int(s[2])
  end_year = int(e[1])
  end_month = int(e[2])

  # 開始日から終了日までのすべての月を生成
  year = start_year
  month = start_month
  while (year < end_year || (year == end_year && month <= end_month)) {
    month_str = sprintf("%04d-%02d", year, month)
    month_idx[month_str] = ++month_count
    months[month_count] = month_str

    # 次の月へ
    month++
    if (month > 12) {
      month = 1
      year++
    }
  }
}
NR == 1 {
  # ヘッダー行はスキップ
  next
}
{
  month = $1
  company = $2
  sales = $3

  # 会社のリストを収集
  if (!(company in company_idx)) {
    company_idx[company] = ++company_count
    companies[company_count] = company
  }

  # 売上データを保存
  data[company, month] = sales
}
END {
  # ヘッダー行を出力（会社名, 月1, 月2, ...）
  header = "会社名"
  for (m = 1; m <= month_count; m++) {
    header = header OFS months[m]
  }
  print header

  # 各会社のデータを出力
  for (c = 1; c <= company_count; c++) {
    company = companies[c]
    row = "\"" company "\""
    for (m = 1; m <= month_count; m++) {
      month = months[m]
      if ((company, month) in data) {
        row = row OFS data[company, month]
      } else {
        row = row OFS "0"
      }
    }
    print row
  }
}
' "$TEMP_FILE" > "$OUTPUT_FILE"

echo "CSVファイルを出力しました: $OUTPUT_FILE"
