# extract-orders-to-csv-with-args.sh

指定した期間の注文データをCSVファイルに出力するスクリプトです。

## 使い方

```bash
./scripts/extract-orders-to-csv-with-args.sh <開始日> <終了日>
```

## 引数

| 引数 | 必須 | 説明 | 形式 |
|------|------|------|------|
| 開始日 | ○ | 抽出期間の開始日 | YYYY-MM-DD |
| 終了日 | ○ | 抽出期間の終了日 | YYYY-MM-DD |

## 使用例

```bash
# 2024年全体
./scripts/extract-orders-to-csv-with-args.sh 2024-01-01 2024-12-31

# 2024年第1四半期
./scripts/extract-orders-to-csv-with-args.sh 2024-01-01 2024-03-31

# 2024年6月のみ
./scripts/extract-orders-to-csv-with-args.sh 2024-06-01 2024-06-30
```

## 動作

1. 引数をチェック（2つの引数が必須）
2. プロジェクトルートの `.env` ファイルを読み込む
3. 環境変数をチェック
4. 指定期間の注文データを抽出
5. `output/` ディレクトリにCSVファイルを出力

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

## 出力ファイル

- ファイル名: `output/orders_{開始日}_{終了日}.csv`
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

## エラー

引数が不足している場合：

```
使い方: ./scripts/extract-orders-to-csv-with-args.sh <開始日> <終了日>
例: ./scripts/extract-orders-to-csv-with-args.sh 2024-01-01 2024-12-31
```

## 関連スクリプト

- [extract-orders-to-csv.sh](extract-orders-to-csv.md) - 固定期間（2024年）版
- [execute-sql.sh](execute-sql.md) - 汎用SQL実行スクリプト
