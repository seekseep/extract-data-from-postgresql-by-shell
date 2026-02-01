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
OUTPUT_FILE="$PROJECT_ROOT/output/orders_${START_DATE}_${END_DATE}.csv"

# 出力ディレクトリ作成
mkdir -p "$PROJECT_ROOT/output"

# SQLクエリ
SQL="
COPY (
  SELECT
    o.order_id AS 注文ID,
    o.ordered_at AS 注文日,
    o.status AS ステータス,
    r.name AS 地域名,
    c.name AS 会社名,
    d.name AS 部署名,
    e.name AS 担当者名,
    COUNT(oi.order_item_id) AS 明細数,
    SUM(oi.quantity * oi.unit_price) AS 合計金額
  FROM orders o
  JOIN departments d ON o.department_id = d.department_id
  JOIN companies c ON d.company_id = c.company_id
  JOIN regions r ON c.region_id = r.region_id
  LEFT JOIN employees e ON o.assigned_employee_id = e.employee_id
  LEFT JOIN order_items oi ON o.order_id = oi.order_id
  WHERE o.ordered_at >= '${START_DATE}'
    AND o.ordered_at <= '${END_DATE}'
  GROUP BY o.order_id, o.ordered_at, o.status, r.name, c.name, d.name, e.name
  ORDER BY o.ordered_at, o.order_id
) TO STDOUT WITH CSV HEADER
"

# SQL実行してCSV出力
PGPASSWORD="$POSTGRES_PASSWORD" psql \
  -h "$POSTGRES_HOST" \
  -p "$POSTGRES_PORT" \
  -U "$POSTGRES_USER" \
  -d "$POSTGRES_DB" \
  -c "$SQL" > "$OUTPUT_FILE"

echo "CSVファイルを出力しました: $OUTPUT_FILE"
