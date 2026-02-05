#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# 引数チェック
if [ $# -ne 2 ]; then
  echo "使い方: $0 <開始日> <終了日>"
  echo "例:     $0 2024-01-01 2024-12-31"
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

echo "ジョブを実行中... (期間: ${START_DATE} 〜 ${END_DATE})"

# ストアドプロシージャを実行してジョブIDを取得
JOB_ID=$(PGPASSWORD="$POSTGRES_PASSWORD" psql \
  -h "$POSTGRES_HOST" \
  -p "$POSTGRES_PORT" \
  -U "$POSTGRES_USER" \
  -d "$POSTGRES_DB" \
  -t -A \
  -c "SELECT insert_order_summary_job('${START_DATE}'::date, '${END_DATE}'::date);")

echo "ジョブID: ${JOB_ID}"

# ジョブの結果を表示
echo ""
echo "=== ジョブのステータス ==="
PGPASSWORD="$POSTGRES_PASSWORD" psql \
  -h "$POSTGRES_HOST" \
  -p "$POSTGRES_PORT" \
  -U "$POSTGRES_USER" \
  -d "$POSTGRES_DB" \
  -c "SELECT id, status FROM jobs WHERE id = ${JOB_ID};"

echo ""
echo "=== ジョブの結果（CSV） ==="
PGPASSWORD="$POSTGRES_PASSWORD" psql \
  -h "$POSTGRES_HOST" \
  -p "$POSTGRES_PORT" \
  -U "$POSTGRES_USER" \
  -d "$POSTGRES_DB" \
  -t -A \
  -c "SELECT convert_from(result, 'UTF8') FROM jobs WHERE id = ${JOB_ID};"
