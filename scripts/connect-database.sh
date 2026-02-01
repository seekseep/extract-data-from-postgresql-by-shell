#!/bin/bash

# コマンドがエラーになったらスクリプトを即座に終了する
set -e

# .env ファイルを読み込む
ENV_FILE=".env"
export $(grep -v '^#' "$ENV_FILE" | xargs)

echo "=== PostgreSQL データベース接続確認 ==="
echo ""

# 接続確認
# psql -h <host> -U <user> -d <database> -p <port> -c "\conninfo"
# 環境変数から情報を取得して接続
PGPASSWORD=$POSTGRES_PASSWORD psql -h localhost -U $POSTGRES_USER -d $POSTGRES_DB -p $POSTGRES_PORT -c "\conninfo"
