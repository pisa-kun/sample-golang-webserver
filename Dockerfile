# 使用するベースイメージを指定 (Golang公式イメージ)
FROM golang:1.21-alpine as builder

# 作業ディレクトリを設定
WORKDIR /app

# go.mod と go.sum をコピー（依存関係のキャッシュを活用するため）
COPY go.mod go.sum ./
RUN go mod download

# ソースコードをコピー
COPY . .

# アプリケーションをビルド
RUN go build -o myapp .

# 本番用の軽量なアルパインイメージを使用
FROM alpine:latest

# 作業ディレクトリを設定
WORKDIR /root/

# ビルドした実行ファイルをコピー
COPY --from=builder /app/myapp .

# コンテナ起動時に実行されるコマンド
CMD ["./myapp"]

# 8080ポートを開放
EXPOSE 8080
