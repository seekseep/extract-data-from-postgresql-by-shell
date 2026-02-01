# extract-data-from-postgresql-by-shell

シェルスクリプトを使用してPostgreSQLからデータを抽出するサンプルプロジェクトです。

## プロジェクト概要

このプロジェクトでは、以下のことを学べます：

- シェルスクリプトからPostgreSQLに接続する方法
- SQLを実行してCSVファイルにデータを出力する方法
- テンプレートSQLと変数ファイルを使った汎用的なデータ抽出

## ディレクトリ構成

```
.
├── scripts/          # 実行スクリプト
├── sql/
│   ├── definition.sql    # テーブル定義
│   ├── seed.sql          # テストデータ
│   └── templates/        # SQLテンプレート
├── variables/        # 変数定義ファイル
├── output/           # 出力先（生成される）
└── docs/             # 各スクリプトの詳細ドキュメント
```

## 環境構築

### 前提条件

- Bash
- psql（PostgreSQLクライアント）

### データベースの準備

データベースは以下のいずれかの方法で準備できます。

#### Docker を使う場合

```bash
# PostgreSQLコンテナを起動
docker run -d \
  --name postgres-sample \
  -e POSTGRES_USER=myuser \
  -e POSTGRES_PASSWORD=mypassword \
  -e POSTGRES_DB=mydb \
  -p 5432:5432 \
  postgres:16
```

#### 既存のデータベースを使う場合

既存のPostgreSQLサーバーに接続する場合は、接続情報を `.env` ファイルに設定してください。

### 環境変数の設定

```bash
# .env.example をコピーして .env を作成
cp .env.example .env

# .env を編集して接続情報を設定
```

## スクリプト一覧

### 環境確認・設定

#### check-tools.sh

必要なツールがインストールされているか確認します。

```bash
./scripts/check-tools.sh
```

[詳細はこちら](docs/check-tools.md)

#### setup-env.sh

`.env.example` から `.env` ファイルを作成します。

```bash
./scripts/setup-env.sh
```

[詳細はこちら](docs/setup-env.md)

#### load-env.sh

`.env` ファイルを読み込んで環境変数を設定します。他のスクリプトから `source` して使用します。

```bash
source ./scripts/load-env.sh
```

[詳細はこちら](docs/load-env.md)

#### connect-database.sh

データベースに接続してpsqlの対話モードに入ります。

```bash
./scripts/connect-database.sh
```

[詳細はこちら](docs/connect-database.md)

### データベースセットアップ

#### setup-table.sh

`sql/definition.sql` を実行してテーブルを作成します。既存テーブルがある場合は削除してから再作成します。

```bash
./scripts/setup-table.sh
```

[詳細はこちら](docs/setup-table.md)

#### setup-data.sh

`sql/seed.sql` を実行してテストデータを投入します。

```bash
./scripts/setup-data.sh
```

[詳細はこちら](docs/setup-data.md)

### データ抽出

#### extract-orders-to-csv.sh

2024年の注文データをCSVファイルに出力します（期間はハードコーディング）。

```bash
./scripts/extract-orders-to-csv.sh
# -> output/orders_2024-01-01_2024-12-31.csv が生成される
```

[詳細はこちら](docs/extract-orders-to-csv.md)

#### extract-orders-to-csv-with-args.sh

引数で指定した期間の注文データをCSVファイルに出力します。

```bash
./scripts/extract-orders-to-csv-with-args.sh 2024-01-01 2024-06-30
# -> output/orders_2024-01-01_2024-06-30.csv が生成される
```

[詳細はこちら](docs/extract-orders-to-csv-with-args.md)

#### execute-sql.sh

変数ファイルとSQLテンプレートを指定してCSVを出力する汎用スクリプトです。

```bash
./scripts/execute-sql.sh \
  --variables variables/orders-2024.env \
  --sql sql/templates/orders-summary.sql \
  --output output/orders-2024.csv
```

[詳細はこちら](docs/execute-sql.md)

## クイックスタート

```bash
# 1. ツール確認
./scripts/check-tools.sh

# 2. 環境設定
./scripts/setup-env.sh
# .env を編集して接続情報を設定

# 3. テーブル作成
./scripts/setup-table.sh

# 4. テストデータ投入
./scripts/setup-data.sh

# 5. データ抽出
./scripts/extract-orders-to-csv.sh
```

## ライセンス

MIT
