# CDKでapp runner + RDS(postgreSQL)でデプロイ

goのアプリケーションは cloud-run-tf\main.go を使う

```bash
cd cloud-run-tf

aws ecr get-login-password --region ap-northeast-1 | docker login --username AWS --password-stdin <your-aws-account-id>.dkr.ecr.ap-northeast-1.amazonaws.com

docker tag my-golang-webapp:latest <your-aws-account-id>.dkr.ecr.ap-northeast-1.amazonaws.com/my-golang-webapp:latest

docker push <your-aws-account-id>.dkr.ecr.ap-northeast-1.amazonaws.com/my-golang-webapp:latest
```