# setup-database.sh

データベースのセットアップ（テーブル作成・ストアドプロシージャ作成・テストデータ投入）をまとめて実行するスクリプトです。

## 使い方

```bash
./scripts/setup-database.sh
```

## 動作

1. プロジェクトルートの `.env` ファイルを読み込む
2. 環境変数をチェック（必須項目が未設定の場合はエラー）
3. `sql/definition.sql` を実行してテーブルを作成
4. `sql/stored-routine.sql` を実行してストアドプロシージャを作成
5. `sql/seed.sql` を実行してテストデータを投入

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
| POSTGRES_HOST | - | localhost | ホスト名 |

## 作成されるテーブル

`sql/definition.sql` で定義された以下のテーブルが作成されます：

- regions（地域）
- companies（会社）
- departments（部署）
- employees（従業員）
- product_categories（商品カテゴリ）
- products（商品）
- orders（注文）
- order_items（注文明細）
- jobs（ジョブ）

## 作成されるストアドプロシージャ

`sql/stored-routine.sql` で定義された以下のストアドプロシージャが作成されます：

- `insert_order_summary_job(date, date)` - 注文サマリーをジョブに挿入する

## 注意

- このスクリプトは冪等性があります（既存テーブルを削除してから再作成）
- 既存データは削除されるため、本番環境での実行には注意が必要です

## 出力例

```
definition.sql の実行が完了しました
stored-routine.sql の実行が完了しました
seed.sql の実行が完了しました

データベースのセットアップが完了しました
```
