# 構成
- Cloud Run で Go 言語のアプリケーションをホスト。
- Cloud SQL (PostgreSQL) へ接続して、データベースのバージョン情報を取得して画面に表示。
- Terraform でインフラのデプロイ。
- ローカル環境 での開発もサポート。

# 手順
1. Go言語のアプリケーション作成
2. Dockerfile作成
3. Terraformの設定
4. ローカル環境での開発
5. デプロイと動作確認

---

1. Go言語のアプリケーション作成
2. Dockerfile作成
```bash
go mod init github.com/pisa-kun/cloud-run-tf

go get "github.com/lib/pq"
```

#### dockerで動かす場合
`docker-compose.yml`を準備しているので、docker compose コマンドでpostgreSQLとwebアプリをローカルで起動と接続できる

```bash
docker-compose up --build
```