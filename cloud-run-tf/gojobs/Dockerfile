# ベースイメージの指定
FROM golang:1.20-alpine

# 作業ディレクトリを作成
WORKDIR /app

# go.mod と go.sum をコピー
COPY go.mod go.sum ./

# 依存関係をインストール
RUN go mod tidy

# ソースコードをコピー
COPY . .

# Goのアプリケーションをビルド
RUN go build -o app .

# コンテナ起動時に実行するコマンド
CMD ["./app"]
