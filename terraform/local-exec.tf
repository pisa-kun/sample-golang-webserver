resource "null_resource" "build_and_push_docker_image" {
  depends_on = [aws_ecr_repository.app_runner_image]

  // ecr作成後にdocker imageをpushする
  // シェルスクリプトを実行し、Terraform の変数を引数として渡す
  // TODO: Windows特化になっているので他OSでも使えるように
  // sh ./deploy.sh ${var.region} ${aws_ecr_repository.app_runner_image.repository_url}
  provisioner "local-exec" {
    command = <<EOT
      powershell -ExecutionPolicy ByPass -Command "./deploy.ps1 '${var.region}' '${aws_ecr_repository.app_runner_image.repository_url}'"
    EOT
  }
}