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
docker-compose restart
```

ローカルで起動時に、アプリ側がpostgreSQLが立ち上がるまで待機する必要あり(アプリ側のコンテナは落ちる)

コンテナとボリュームを停止して削除する場合は-vつけること

```bash
docker-compose down -v
```

**補足: PostgreSQLのバージョンを更新した場合**

ボリュームを削除する必要がある。

> docker volume rm cloud-run-tf_postgres_data

3. Terraformの設定
Google Cloud SDK のインストールと認証

```bash
gcloud auth login
gcloud auth application-default login
gcloud config configurations list
gcloud config set project YOUR_PROJECT_ID
```

認証の追加

```bash
gcloud services enable sqladmin.googleapis.com
gcloud services enable vpcaccess.googleapis.com
gcloud services enable servicenetworking.googleapis.com

```

Artifact Registry の作成

```bash
gcloud services enable artifactregistry.googleapis.com
# Artifact Registry に対して操作を行うためには、Google Cloud の認証情報を適切に設定する必要
gcloud auth configure-docker us-central1-docker.pkg.dev
gcloud artifacts repositories create YOUR_REPOSITORY_NAME --repository-format=docker --location=us-central1
```

Docker イメージのビルド
Go アプリケーションのディレクトリに移動して、Docker イメージをビルドします。

```bash
docker build -t us-central1-docker.pkg.dev/YOUR_PROJECT_ID/YOUR_REPOSITORY_NAME/your-image-name .
```

*macの場合、 --platform linux/amd64

Artifact Registry へ Docker イメージを Push

```bash
docker push us-central1-docker.pkg.dev/YOUR_PROJECT_ID/YOUR_REPOSITORY_NAME/your-image-name
```

これで、Docker イメージが Artifact Registry にアップロードされました。

### Terraform 実行

terraform init
terraform plan
terraform apply

<https://zenn.dev/ring_belle/books/gcp-cloudrun-terraform/viewer/cloudrun-basic>

### Cloud SQLにデータ挿入

Cloud SQL Studioからアクセスして挿入する。

## API Gatewayの追加

<https://zenn.dev/cloud_ace/articles/f863f83a0f75dd>

1. Google Cloud APIの有効化

```bash
gcloud services enable apigateway.googleapis.com         # API Gateway API
gcloud services enable servicemanagement.googleapis.com  # Service Management API
gcloud services enable servicecontrol.googleapis.com     # Service Control API
```

### API Gatewayにレートリミット追加

openapi.yamlに記載する。
