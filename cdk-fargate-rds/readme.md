# CDK Fargate RDS プロジェクト

このプロジェクトでは、Go 言語を使った Web サーバーと PostgreSQL を Docker Compose でローカル開発環境でセットアップし、最終的に AWS CDK を使って Fargate と RDS をデプロイする手順をまとめています。

## 目次
1. [前提条件](#前提条件)
2. [手順](#手順)
   1. [Go Web サーバーのセットアップ](#go-web-サーバーのセットアップ)
   2. [Docker Compose のセットアップ](#docker-compose-のセットアップ)
   3. [アプリケーションと DB の接続確認](#アプリケーションと-db-の接続確認)
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


---

## 参考資料

- [Go 言語公式](https://golang.org/)
- [Docker 公式ドキュメント](https://docs.docker.com/)
- [Docker Compose 公式ドキュメント](https://docs.docker.com/compose/)
- [PostgreSQL 公式ドキュメント](https://www.postgresql.org/)
