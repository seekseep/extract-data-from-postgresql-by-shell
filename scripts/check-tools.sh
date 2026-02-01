#!/bin/bash

# コマンドがエラーになったらスクリプトを即座に終了する
set -e

echo "=== PostgreSQL ツール確認 ==="
echo ""

missing_tools=()

# psql の確認
if command -v psql &> /dev/null; then
  version=$(psql --version | head -n 1)
  echo "✓ psql: $version"
else
  echo "✗ psql: 見つかりません"
  missing_tools+=("psql")
fi

# pg_dump の確認
if command -v pg_dump &> /dev/null; then
  version=$(pg_dump --version | head -n 1)
  echo "✓ pg_dump: $version"
else
  echo "✗ pg_dump: 見つかりません"
  missing_tools+=("pg_dump")
fi

echo ""

if [ ${#missing_tools[@]} -eq 0 ]; then
  echo "すべてのツールがインストールされています"
  exit 0
else
  echo "以下のツールをインストールしてください:"
  for tool in "${missing_tools[@]}"; do
    echo "  - $tool"
  done
  echo ""
  echo "インストール方法:"
  echo "  macOS:  brew install postgresql"
  echo "  Ubuntu: sudo apt install postgresql-client"
  echo "  Windows: https://www.postgresql.org/download/windows/"
  exit 1
fi
