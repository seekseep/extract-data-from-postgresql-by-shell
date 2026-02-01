# connect-database.sh

PostgreSQL データベースへの接続を確認するスクリプトです。

## 使い方

```bash
./scripts/connect-database.sh
```

## 動作

1. プロジェクトルートの `.env` ファイルを読み込む
2. 環境変数を使って PostgreSQL に接続
3. `\conninfo` コマンドで接続情報を表示

## 前提条件

- `.env` ファイルが設定済みであること
- PostgreSQL サーバーが起動していること

## 必要な環境変数

| 変数名 | 必須 | デフォルト値 | 説明 |
|--------|------|-------------|------|
| POSTGRES_USER | ○ | - | データベースユーザー名 |
| POSTGRES_PASSWORD | ○ | - | データベースパスワード |
| POSTGRES_DB | ○ | - | データベース名 |
| POSTGRES_PORT | - | 5432 | ポート番号 |

## 出力例

```
=== PostgreSQL データベース接続確認 ===

You are connected to database "mydb" as user "myuser" on host "localhost" at port "5432".
```

## トラブルシューティング

### 接続エラーが発生する場合

1. PostgreSQL サーバーが起動しているか確認

```bash
docker compose ps
```

2. `.env` ファイルの設定を確認

```bash
cat .env
```

3. ポート番号が正しいか確認

```bash
docker compose logs db
```
