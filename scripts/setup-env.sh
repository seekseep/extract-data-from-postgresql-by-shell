#!/bin/bash

# コマンドがエラーになったらスクリプトを即座に終了する
set -e

ENV_FILE=".env"

# デフォルト値
DEFAULT_USER="postgres"
DEFAULT_PASSWORD="postgres"
DEFAULT_DB="mydb"
DEFAULT_PORT="5432"

echo "=== PostgreSQL 環境変数セットアップ ==="
echo ""

# ユーザー名
read -p "POSTGRES_USER [$DEFAULT_USER]: " input_user
POSTGRES_USER="${input_user:-$DEFAULT_USER}"

# パスワード
read -p "POSTGRES_PASSWORD [$DEFAULT_PASSWORD]: " input_password
POSTGRES_PASSWORD="${input_password:-$DEFAULT_PASSWORD}"

# データベース名
read -p "POSTGRES_DB [$DEFAULT_DB]: " input_db
POSTGRES_DB="${input_db:-$DEFAULT_DB}"

# ポート
read -p "POSTGRES_PORT [$DEFAULT_PORT]: " input_port
POSTGRES_PORT="${input_port:-$DEFAULT_PORT}"

# .env ファイルに書き込み
cat > "$ENV_FILE" << EOF
POSTGRES_USER=$POSTGRES_USER
POSTGRES_PASSWORD=$POSTGRES_PASSWORD
POSTGRES_DB=$POSTGRES_DB
POSTGRES_PORT=$POSTGRES_PORT
EOF

echo ""
echo "=== 設定完了 ==="
echo "$ENV_FILE を作成しました:"
echo ""
cat "$ENV_FILE"
