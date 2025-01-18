param(
    [string]$Region,
    [string]$RepositoryUrl
)

# ECR へのログイン
aws ecr get-login-password --region $Region | docker login --username AWS --password-stdin $RepositoryUrl

# Docker イメージのビルドとプッシュ
docker build -f ..\Dockerfile -t "$RepositoryUrl:latest" .
docker push "$RepositoryUrl:latest"