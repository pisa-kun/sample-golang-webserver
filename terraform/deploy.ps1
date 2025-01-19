param(
    [string]$Region,
    [string]$RepositoryUrl
)

# ECR へのログイン
aws ecr get-login-password --region $Region | docker login --username AWS --password-stdin $RepositoryUrl

# カレントディレクトリを1つ上に移動
Set-Location ..
pwd

# Docker イメージのビルドとプッシュ
#docker build -f .\Dockerfile -t "$RepositoryUrl:latest" .
docker build -t "$RepositoryUrl:latest" .
docker push "$RepositoryUrl:latest"

Set-Location terraform
pwd