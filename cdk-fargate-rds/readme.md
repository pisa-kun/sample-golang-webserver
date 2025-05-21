# CDK Fargate RDS プロジェクト

このプロジェクトでは、Go 言語を使った Web サーバーと PostgreSQL を Docker Compose でローカル開発環境でセットアップし、最終的に AWS CDK を使って Fargate と RDS をデプロイする手順をまとめています。
## 目次
1. [前提条件](#前提条件)
2. [手順](#手順)
   1. [Go Web サーバーのセットアップ](#1-go-web-サーバーのセットアップ)
      1. [Go モジュールの初期化](#11-go-モジュールの初期化)
      2. [必要なパッケージのインストール](#12-必要なパッケージのインストール)
      3. [Go アプリケーションの作成](#13-go-アプリケーションの作成)
   2. [Docker Compose のセットアップ](#2-docker-compose-のセットアップ)
      1. [Dockerfile の作成](#21-dockerfile-の作成)
      2. [docker-compose.yml の作成](#22-docker-composeyml-の作成)
      3. [初期データの作成](#23-初期データの作成)
   3. [アプリケーションと DB の接続確認](#3-アプリケーションと-db-の接続確認)
      1. [Docker コンテナのビルドと起動](#31-docker-コンテナのビルドと起動)
   4. [ECRリポジトリ作成とDockerイメージの登録](#4-ecrリポジトリ作成とdockerイメージの登録)
      1. [環境変数を設定](#40-環境変数を設定)
      2. [ECRリポジトリの作成](#41-ecrリポジトリの作成)
      3. [ECRにログイン](#42-ecrにログイン)
      4. [Dockerイメージをビルド](#43-dockerイメージをビルド)
      5. [イメージにタグをつける](#44-イメージにタグをつける)
      6. [ECRにDockerイメージをプッシュ](#45-ecrにdockerイメージをプッシュ)
   5. [CDKのデプロイ](#5-cdkのデプロイ)
3. [参考資料](#参考資料)

---

## 前提条件

以下のツールがインストールされていることを前提としています。

- **Go**: 1.20以上
- **Docker**: 最新バージョン
- **Docker Compose**: 最新バージョン

## 手順

### 1. Go Web サーバーのセットアップ

まず、Go 言語で Web サーバーを作成します。

#### 1.1 Go モジュールの初期化

Go のプロジェクトを初期化します。

> go mod init cdk-fargate-rds

#### 1.2 必要なパッケージのインストール

PostgreSQL に接続するために `lib/pq` パッケージをインストールします。

> go get github.com/lib/pq

#### 1.3 Go アプリケーションの作成

`main.go` というファイルを作成し、必要なコードを記述します。具体的には、PostgreSQL への接続や、データベースからユーザー情報を取得して表示するコードです。

### 2. Docker Compose のセットアップ

次に、Go アプリケーションと PostgreSQL サーバーを Docker Compose でセットアップします。

#### 2.1 `Dockerfile` の作成

`Dockerfile` を作成し、Go アプリケーションのコンテナイメージをビルドします。内容としては、Go 言語のコンテナを基にし、アプリケーションをコピーしてビルド・実行する設定を記述します。

#### 2.2 `docker-compose.yml` の作成

次に、`docker-compose.yml` を作成し、Go アプリケーションと PostgreSQL サーバーを起動します。これにより、アプリケーションとデータベースが連携する構成を定義します。

#### 2.3 初期データの作成

`db/init.sql` というファイルを作成し、データベースの初期データとして `users` テーブルを作成し、サンプルデータを投入します。

### 3. アプリケーションと DB の接続確認

#### 3.1 Docker コンテナのビルドと起動

以下のコマンドで、アプリケーションと PostgreSQL コンテナをビルドし、起動します。

> docker-compose up --build

初回実行時はアプリがDB接続する際にDBが立ち上がっていないのでエラーになる。ctrl+Cでコンソールを強制終了して再度、docker compose upすること。

その後、ブラウザで [http://localhost:8080](http://localhost:8080) を開き、データベースに格納されているデータが表示されることを確認します。

### 4. ECRリポジトリ作成とDockerイメージの登録

ルートディレクトリで次のコマンドを実行して、イメージをECRへPushする。

#### 4.0 環境変数を設定
まず、アカウントIDとリージョンを環境変数に設定します（毎回手で入力したくない人向け）。

set ACCOUNT_ID=<自身のアカウントIDをセットする。12桁の数字>
set REGION=ap-northeast-1
set REPOSITORY_NAME=cdk-fargate-rds-repository
set ECR_URI=%ACCOUNT_ID%.dkr.ecr.%REGION%.amazonaws.com/%REPOSITORY_NAME%


#### 4.1 ECRリポジトリの作成

> aws ecr create-repository --repository-name $REPOSITORY_NAME --region $REGION

#### 4.2 ECRにログイン

> aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com

#### 4.3 Dockerイメージをビルド

> docker build -t $REPOSITORY_NAME .

#### 4.4 イメージにタグをつける

> docker tag ${REPOSITORY_NAME}:latest ${ECR_URI}:latest

#### 4.5. ECRにDockerイメージをプッシュ

> docker push ${ECR_URI}:latest

### 5. CDKのデプロイ

以下を実行する。
> cd lambda/rds-init

> npm install --omit=dev

アカウントIDをハードコードしないようにしているので、cdk deploy時にecrRepositoryUriに自身のアカウントIDを差し替えて cdkプロジェクトで 次のコマンドを実行する。

> cdk deploy --context ecrRepositoryUri=${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${REPOSITORY_NAME}:latest

---

## 参考資料

- [Go 言語公式](https://golang.org/)
- [Docker 公式ドキュメント](https://docs.docker.com/)
- [Docker Compose 公式ドキュメント](https://docs.docker.com/compose/)
- [PostgreSQL 公式ドキュメント](https://www.postgresql.org/)
