# extract-orders-to-csv.sh

2024年の注文データをCSVファイルに出力するスクリプトです。

## 使い方

```bash
./scripts/extract-orders-to-csv.sh
```

## 動作

1. プロジェクトルートの `.env` ファイルを読み込む
2. 環境変数をチェック
3. 2024年1月1日〜2024年12月31日の注文データを抽出
4. `output/` ディレクトリにCSVファイルを出力

## 前提条件

- `.env` ファイルが設定済みであること
- PostgreSQL サーバーが起動していること
- テーブルとデータが存在すること

## 必要な環境変数

| 変数名 | 必須 | デフォルト値 | 説明 |
|--------|------|-------------|------|
| POSTGRES_USER | ○ | - | データベースユーザー名 |
| POSTGRES_PASSWORD | ○ | - | データベースパスワード |
| POSTGRES_DB | ○ | - | データベース名 |
| POSTGRES_PORT | - | 5432 | ポート番号 |
| POSTGRES_HOST | - | localhost | ホスト名 |

## 抽出期間

このスクリプトでは以下の期間がハードコーディングされています：

- 開始日: 2024-01-01
- 終了日: 2024-12-31

期間を変更したい場合は `extract-orders-to-csv-with-args.sh` を使用してください。

## 出力ファイル

- ファイル名: `output/orders_2024-01-01_2024-12-31.csv`
- 形式: CSV（ヘッダー付き）

## 出力カラム

| カラム名 | 説明 |
|---------|------|
| 注文ID | orders.order_id |
| 注文日 | orders.ordered_at |
| ステータス | orders.status |
| 地域名 | regions.name |
| 会社名 | companies.name |
| 部署名 | departments.name |
| 担当者名 | employees.name |
| 明細数 | order_items の件数 |
| 合計金額 | 数量 × 単価 の合計 |

## 出力例

```
CSVファイルを出力しました: /path/to/output/orders_2024-01-01_2024-12-31.csv
```

## 関連スクリプト

- [extract-orders-to-csv-with-args.sh](extract-orders-to-csv-with-args.md) - 期間を引数で指定可能
- [execute-sql.sh](execute-sql.md) - 汎用SQL実行スクリプト
