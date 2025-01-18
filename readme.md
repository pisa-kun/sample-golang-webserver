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

#### app runnerがs3にアクセスするIAMロールを作成する

1. 信頼関係ポリシードキュメントを作成する
まず、App Runnerサービスがロールを引き受けることができるようにする信頼関係ポリシーを作成します。これにより、App Runnerが指定されたIAMロールを使用できるようになります。

以下のコマンドを実行し、信頼関係ポリシーを記述したJSONファイルを作成します。

```
cat << EOF > apprunner-role-policy.json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "tasks.apprunner.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
```

2. IAMロールの作成
次に、上記の信頼関係ポリシーを使用して、App Runner専用のIAMロールを作成します。このロールは、App Runnerのインスタンスが実行するために使用されます。

以下のコマンドを実行して、apprunner-s3-roleという名前のIAMロールを作成します。

```bash
aws iam create-role --role-name apprunner-s3-role --path '/apprunner/' --assume-role-policy-document file://apprunner-role-policy.json
```

3. Amazon S3アクセス用のポリシーをアタッチ
App RunnerがAmazon S3にアクセスするためには、適切なアクセス権限を付与する必要があります。これを実現するために、AmazonS3FullAccessやAmazonS3ReadOnlyAccessなどのAWS管理ポリシーをIAMロールにアタッチします。

ここでは、AmazonS3FullAccessポリシーをアタッチして、S3への読み書きアクセスを許可します。

以下のコマンドを実行して、作成したIAMロールにS3のアクセス権限をアタッチします。

```bash
aws iam attach-role-policy --role-name apprunner-s3-role --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess
```

4. App Runner アプリケーションにIAMロールを関連付ける
最後に、App Runnerサービスに作成したIAMロールを関連付けます。この操作は、AWSマネジメントコンソールまたはAWS CLIで行いますが、CLIで行う場合は次のように設定できます。

まず、App Runnerサービスの詳細情報を取得し、ロールを設定します。

```bash
aws apprunner update-service \
  --service-arn <app-runner-service-arn> \
  --instance-role arn:aws:iam::<aws-account-id>:role/apprunner-s3-role
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

### ecr作成時にdockerイメージをpushする

https://qiita.com/suzuki-navi/items/613311d1a31d0306be0d