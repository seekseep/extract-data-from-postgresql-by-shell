# execute-sql.sh

SQLテンプレートと変数ファイルを使ってクエリを実行し、CSVを出力する汎用スクリプトです。

## 使い方

```bash
./scripts/execute-sql.sh --variables <変数ファイル> --sql <SQLファイル> --output <出力ファイル>
```

## オプション

| オプション | 短縮形 | 必須 | 説明 |
|-----------|--------|------|------|
| --variables | -v | ○ | 変数定義ファイル（key=value形式） |
| --sql | -s | ○ | SQLテンプレートファイル |
| --output | -o | ○ | 出力CSVファイル |
| --help | -h | - | ヘルプを表示 |

## 使用例

```bash
# 2024年の注文概要を出力
./scripts/execute-sql.sh \
  --variables variables/orders-2024.env \
  --sql sql/templates/orders-summary.sql \
  --output output/orders-2024.csv

# 関東地域の注文明細を出力
./scripts/execute-sql.sh \
  -v variables/order-details-kanto-2024.env \
  -s sql/templates/order-details-by-region.sql \
  -o output/order-details-kanto-2024.csv
```

## 変数ファイルの形式

```env
# コメント行
key1=value1
key2=value2
```

例（`variables/orders-2024.env`）:

```env
# 注文抽出用変数
start_date=2024-01-01
end_date=2024-12-31
```

## SQLテンプレートの書き方

変数は `:'変数名'` の形式で記述します。これは psql の `-v` オプションで置換されます。

```sql
WHERE o.ordered_at >= :'start_date'
  AND o.ordered_at <= :'end_date'
```

## 動作

1. 引数をパースしてファイルパスを取得
2. 変数ファイルとSQLファイルの存在をチェック
3. `.env` ファイルからDB接続情報を読み込む
4. 変数ファイルから psql の `-v` オプションを構築
5. SQLテンプレートを実行してCSVを出力

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

## 利用可能なSQLテンプレート

| ファイル | 説明 | 必要な変数 |
|---------|------|-----------|
| sql/templates/orders-summary.sql | 注文概要 | start_date, end_date |
| sql/templates/order-details-by-region.sql | 地域別注文明細 | region, start_date, end_date |

## 新しいテンプレートの作成

1. `sql/templates/` に新しいSQLファイルを作成
2. 変数は `:'変数名'` の形式で記述
3. `COPY (...) TO STDOUT WITH CSV HEADER` で結果を出力

例:

```sql
COPY (
  SELECT column1, column2
  FROM table
  WHERE date >= :'start_date'
    AND date <= :'end_date'
) TO STDOUT WITH CSV HEADER
```

## エラー

```
エラー: すべてのオプションが必要です
エラー: 変数ファイルが見つかりません: xxx
エラー: SQLファイルが見つかりません: xxx
```

## 関連ファイル

- [変数ファイルの例](../variables/)
- [SQLテンプレートの例](../sql/templates/)
