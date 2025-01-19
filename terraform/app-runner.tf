resource "aws_apprunner_service" "example" {
  service_name = var.app_runner_name

  source_configuration {
    # 作成したIAMロールを指定
    authentication_configuration {
      access_role_arn = aws_iam_role.role.arn
    }
    
    image_repository {
      image_configuration {
        # Health Checkがあるので、port番号は正しいか注意
        port = "8080"
      }
      image_identifier      = "${aws_ecr_repository.app_runner_image.repository_url}:latest"
      image_repository_type = "ECR"
    }
  }

  tags = {
    Name = "example-apprunner-service"
  }
}
