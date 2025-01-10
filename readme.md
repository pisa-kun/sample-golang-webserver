## App Runnerにgoのwebアプリをデプロイするまで

### goのwebアプリ

#### ローカルで起動する場合

```bash
# すでにポートが起動している場合
kill -9 $(lsof -t -i :3000)
go run main.go
```

#### dockerで動かす場合
```bash
# イメージをビルド
docker build -t my-golang-webapp .

# ローカルで動作確認
docker run -p 8080:8080 my-golang-webapp
```

### AWS ECRにデプロイ

AWS ECRにデプロイするための手順です。

1. ECRリポジトリを作成

AWSコンソールやAWS CLIを使って、ECRリポジトリを作成します。

```bash
aws ecr create-repository --repository-name my-golang-webapp
```
2. ECRにログイン

DockerをECRにログインさせるために、以下のコマンドを実行します。

```bash
aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin <your-aws-account-id>.dkr.ecr.us-west-2.amazonaws.com
```
3. タグを付けてプッシュ

ビルドしたDockerイメージにECRリポジトリのタグを付け、プッシュします。

```bash
docker tag my-golang-webapp:latest <your-aws-account-id>.dkr.ecr.us-west-2.amazonaws.com/my-golang-webapp:latest
docker push <your-aws-account-id>.dkr.ecr.us-west-2.amazonaws.com/my-golang-webapp:latest
```