# setup-env.sh

`.env.example` から `.env` ファイルを作成するスクリプトです。

## 使い方

```bash
./scripts/setup-env.sh
```

## 動作

1. `.env` ファイルが既に存在する場合は何もしない
2. `.env.example` を `.env` にコピー
3. ユーザーに `.env` を編集するよう案内

## 環境変数

`.env` ファイルで設定する環境変数：

| 変数名 | 説明 | 例 |
|--------|------|-----|
| POSTGRES_HOST | データベースホスト | localhost |
| POSTGRES_PORT | ポート番号 | 5432 |
| POSTGRES_USER | ユーザー名 | myuser |
| POSTGRES_PASSWORD | パスワード | mypassword |
| POSTGRES_DB | データベース名 | mydb |
