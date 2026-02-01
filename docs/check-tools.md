# check-tools.sh

必要なツールがインストールされているか確認するスクリプトです。

## 使い方

```bash
./scripts/check-tools.sh
```

## 確認するツール

- `psql` - PostgreSQLクライアント

## 出力例

```
psql が見つかりました: psql (PostgreSQL) 16.0
すべてのツールが利用可能です
```

## 終了コード

- `0` - すべてのツールが利用可能
- `1` - 必要なツールが見つからない
