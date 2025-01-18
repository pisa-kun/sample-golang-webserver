#!/bin/bash

# 引数として渡された変数を利用
REGION=$1
REPOSITORY_URL=$2

# ECR へのログイン
aws ecr get-login-password --region "$REGION" | docker login --username AWS --password-stdin "$REPOSITORY_URL"

# Docker イメージのビルドとプッシュ
docker build -f ../Dockerfile -t "$REPOSITORY_URL:latest" .
docker push "$REPOSITORY_URL:latest"
