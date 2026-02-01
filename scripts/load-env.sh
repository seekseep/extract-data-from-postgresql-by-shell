#!/bin/bash

set -e

ENV_FILE=".env"

# grep -v '^#' "$ENV_FILE" '#' で始まるコメント行を除外
# |                        パイプで次のコマンドへ
# xargs                    複数行を1行のスペース区切りに変換
# export $(...)            結果を環境変数としてエクスポート
export $(grep -v '^#' "$ENV_FILE" | xargs)

echo $POSTGRES_USER
echo $POSTGRES_PASSWORD
echo $POSTGRES_DB
echo $POSTGRES_PORT
