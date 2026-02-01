#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# ヘルプ表示
show_help() {
  echo "使い方: $0 --variables <変数ファイル> --sql <SQLファイル> --output <出力ファイル>"
  echo ""
  echo "オプション:"
  echo "  --variables, -v  変数定義ファイル（key=value形式）"
  echo "  --sql, -s        SQLテンプレートファイル"
  echo "  --output, -o     出力CSVファイル"
  echo "  --help, -h       このヘルプを表示"
  echo ""
  echo "例:"
  echo "  $0 --variables variables/orders-2024.env --sql sql/templates/orders-summary.sql --output output/orders.csv"
}

# 引数パース
VARIABLES_FILE=""
SQL_FILE=""
OUTPUT_FILE=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --variables|-v)
      VARIABLES_FILE="$2"
      shift 2
      ;;
    --sql|-s)
      SQL_FILE="$2"
      shift 2
      ;;
    --output|-o)
      OUTPUT_FILE="$2"
      shift 2
      ;;
    --help|-h)
      show_help
      exit 0
      ;;
    *)
      echo "不明なオプション: $1"
      show_help
      exit 1
      ;;
  esac
done

# 必須引数チェック
if [ -z "$VARIABLES_FILE" ] || [ -z "$SQL_FILE" ] || [ -z "$OUTPUT_FILE" ]; then
  echo "エラー: すべてのオプションが必要です"
  show_help
  exit 1
fi

# ファイル存在チェック
if [ ! -f "$VARIABLES_FILE" ]; then
  echo "エラー: 変数ファイルが見つかりません: $VARIABLES_FILE"
  exit 1
fi

if [ ! -f "$SQL_FILE" ]; then
  echo "エラー: SQLファイルが見つかりません: $SQL_FILE"
  exit 1
fi

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

# 出力ディレクトリ作成
OUTPUT_DIR=$(dirname "$OUTPUT_FILE")
mkdir -p "$OUTPUT_DIR"

# 変数ファイルから psql の -v オプションを構築
PSQL_VARS=""
while IFS='=' read -r key value || [ -n "$key" ]; do
  # 空行とコメント行をスキップ
  [[ -z "$key" || "$key" =~ ^# ]] && continue
  # 値の前後の空白を削除
  key=$(echo "$key" | xargs)
  value=$(echo "$value" | xargs)
  PSQL_VARS="$PSQL_VARS -v ${key}=${value}"
done < "$VARIABLES_FILE"

# SQL実行してCSV出力
PGPASSWORD="$POSTGRES_PASSWORD" psql \
  -h "$POSTGRES_HOST" \
  -p "$POSTGRES_PORT" \
  -U "$POSTGRES_USER" \
  -d "$POSTGRES_DB" \
  $PSQL_VARS \
  -f "$SQL_FILE" > "$OUTPUT_FILE"

echo "CSVファイルを出力しました: $OUTPUT_FILE"
