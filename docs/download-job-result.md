# download-job-result.sh

ジョブの結果をCSVファイルとしてダウンロードするスクリプトです。

## 使い方

```bash
./scripts/download-job-result.sh <ジョブID> [出力ファイル]
```

## 引数

| 引数 | 必須 | 説明 | デフォルト値 |
|------|------|------|-------------|
| ジョブID | ○ | ダウンロードするジョブのID | - |
| 出力ファイル | - | 保存先のファイルパス | `output/job_<ジョブID>_result.csv` |

## 使用例

```bash
# デフォルトのファイル名で保存
./scripts/download-job-result.sh 1
# -> output/job_1_result.csv が生成される

# ファイル名を指定して保存
./scripts/download-job-result.sh 1 output/my-result.csv
```

## 動作

1. 引数をチェック（ジョブIDが必須）
2. `output/` ディレクトリを作成
3. プロジェクトルートの `.env` ファイルを読み込む
4. 環境変数をチェック
5. ジョブのステータスを確認（`completed` でなければエラー）
6. `convert_from(result, 'UTF8')` で結果をテキストに変換してファイルに保存

## 前提条件

- `.env` ファイルが設定済みであること
- PostgreSQL サーバーが起動していること
- 対象のジョブが `completed` 状態であること

## 必要な環境変数

| 変数名 | 必須 | デフォルト値 | 説明 |
|--------|------|-------------|------|
| POSTGRES_USER | ○ | - | データベースユーザー名 |
| POSTGRES_PASSWORD | ○ | - | データベースパスワード |
| POSTGRES_DB | ○ | - | データベース名 |
| POSTGRES_PORT | - | 5432 | ポート番号 |
| POSTGRES_HOST | - | localhost | ホスト名 |

## 出力例

```
ジョブID: 1 (ステータス: completed)
保存しました: output/job_1_result.csv
```

## エラー

```
エラー: ジョブID 99 が見つかりません
エラー: ジョブが完了していません (ステータス: running)
```

## 関連スクリプト

- [run-order-summary-job.md](run-order-summary-job.md) - ジョブの実行
