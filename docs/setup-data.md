# setup-data.sh

テストデータをデータベースに投入するスクリプトです。

## 使い方

```bash
./scripts/setup-data.sh
```

## 動作

1. プロジェクトルートの `.env` ファイルを読み込む
2. 環境変数をチェック（必須項目が未設定の場合はエラー）
3. `sql/seed.sql` を実行してテストデータを投入

## 前提条件

- `.env` ファイルが設定済みであること
- PostgreSQL サーバーが起動していること
- テーブルが作成済みであること（`setup-table.sh` を実行済み）
- `sql/seed.sql` が存在すること

## 必要な環境変数

| 変数名 | 必須 | デフォルト値 | 説明 |
|--------|------|-------------|------|
| POSTGRES_USER | ○ | - | データベースユーザー名 |
| POSTGRES_PASSWORD | ○ | - | データベースパスワード |
| POSTGRES_DB | ○ | - | データベース名 |
| POSTGRES_PORT | - | 5432 | ポート番号 |
| POSTGRES_HOST | - | localhost | ホスト名 |

## 投入されるデータ

`sql/seed.sql` で定義された以下のテストデータが投入されます：

| テーブル | 件数 | 説明 |
|---------|------|------|
| regions | 9件 | 北海道〜九州・沖縄の地域 |
| companies | 10件 | 各地域の会社 |
| departments | 20件 | 各会社の部署 |
| employees | 200件 | 各部署の従業員 |
| product_categories | 5件 | 商品カテゴリ |
| products | 100件 | 各カテゴリの商品 |
| orders | 30件 | 2024年の注文 |
| order_items | 153件 | 注文明細 |

## 実行順序

必ず `setup-table.sh` の後に実行してください。

```bash
./scripts/setup-table.sh
./scripts/setup-data.sh
```

## 出力例

```
INSERT 0 9
INSERT 0 10
...
seed.sql の実行が完了しました
```
