# load-env.sh

`.env` ファイルを読み込んで環境変数を設定するスクリプトです。

## 使い方

このスクリプトは `source` コマンドで読み込んで使用します。

```bash
source ./scripts/load-env.sh
```

## 動作

1. プロジェクトルートの `.env` ファイルを探す
2. ファイルが存在すれば環境変数として読み込む
3. コメント行（`#` で始まる行）はスキップ

## 注意

- 直接実行（`./scripts/load-env.sh`）しても、現在のシェルに環境変数は設定されません
- 必ず `source` または `.` で読み込んでください

```bash
# OK
source ./scripts/load-env.sh

# OK
. ./scripts/load-env.sh

# NG（環境変数が設定されない）
./scripts/load-env.sh
```
