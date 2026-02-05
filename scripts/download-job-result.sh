#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# 引数チェック
if [ $# -lt 1 ] || [ $# -gt 2 ]; then
  echo "使い方: $0 <ジョブID> [出力ファイル]"
  echo "例:     $0 1 output.csv"
  exit 1
fi

JOB_ID="$1"
OUTPUT_DIR="$PROJECT_ROOT/output"
mkdir -p "$OUTPUT_DIR"
OUTPUT_FILE="${2:-${OUTPUT_DIR}/job_${JOB_ID}_result.csv}"

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

# ジョブのステータスを確認
STATUS=$(PGPASSWORD="$POSTGRES_PASSWORD" psql \
  -h "$POSTGRES_HOST" \
  -p "$POSTGRES_PORT" \
  -U "$POSTGRES_USER" \
  -d "$POSTGRES_DB" \
  -t -A \
  -c "SELECT status FROM jobs WHERE id = ${JOB_ID};")

if [ -z "$STATUS" ]; then
  echo "エラー: ジョブID ${JOB_ID} が見つかりません"
  exit 1
fi

echo "ジョブID: ${JOB_ID} (ステータス: ${STATUS})"

if [ "$STATUS" != "completed" ]; then
  echo "エラー: ジョブが完了していません (ステータス: ${STATUS})"
  exit 1
fi

# resultをダウンロードしてファイルに保存
PGPASSWORD="$POSTGRES_PASSWORD" psql \
  -h "$POSTGRES_HOST" \
  -p "$POSTGRES_PORT" \
  -U "$POSTGRES_USER" \
  -d "$POSTGRES_DB" \
  -t -A \
  -c "SELECT convert_from(result, 'UTF8') FROM jobs WHERE id = ${JOB_ID};" \
  > "$OUTPUT_FILE"

echo "保存しました: ${OUTPUT_FILE}"
