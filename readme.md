## App Runnerにgoのwebアプリをデプロイするまで

### goのwebアプリ
#### 事前準備

```bash
go mod init github.com/pisa-kun/sample-golang-webserver
```

#### ローカルで起動する場合

```bash
# すでにポートが起動している場合
kill -9 $(lsof -t -i :3000) // mac
go run main.go
```

exe形式で実行する場合
```bash
# すでにポートが起動している場合
kill -9 $(lsof -t -i :3000)
go build -o myapp.exe .
myapp.exe
```

#### dockerで動かす場合
```bash
# イメージをビルド
docker build -t my-golang-webapp .

# ローカルで動作確認
docker run -p 8080:8080 my-golang-webapp
```

credentialsをもとにローカルでaws s3にアクセスさせる際はdocker-compose.ymlのvolumeを指定する。

```yaml
services:
  app:
    # 使用するイメージが存在しない場合、ビルドする
    build:
      context: .
      dockerfile: Dockerfile
    volumes:
      # ソースコードをコンテナ内にマウント（変更をコンテナ内で反映）
      - .:/app
      # 認証情報をコンテナに渡す
      - ~/.aws/:/root/.aws
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
aws ecr get-login-password --region ap-northeast-1 | docker login --username AWS --password-stdin <your-aws-account-id>.dkr.ecr.ap-northeast-1.amazonaws.com
```
3. タグを付けてプッシュ

ビルドしたDockerイメージにECRリポジトリのタグを付け、プッシュします。

```bash
docker tag my-golang-webapp:latest <your-aws-account-id>.dkr.ecr.ap-northeast-1.amazonaws.com/my-golang-webapp:latest
docker push <your-aws-account-id>.dkr.ecr.ap-northeast-1.amazonaws.com/my-golang-webapp:latest
```

### aws sdkでs3にアクセスする
dockerで起動するwebアプリがS3にアクセスするように設定する。

1. go getでsdkインストールする。

```bash
go get github.com/aws/aws-sdk-go
```

### CDKプロジェクトの初期化

```bash
cdk init app --language go
```

モジュールのダウンロード
```bash
go mod download github.com/aws/aws-cdk-go/awscdk/v2
go mod download github.com/aws/constructs-go/constructs/v10
go mod download github.com/aws/jsii-runtime-go
```

go.modとgo.sumの更新
```bash
go mod tidy
```