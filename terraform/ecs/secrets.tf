resource "aws_secretsmanager_secret" "app_config" {
  name = "${var.project_name}-app-config"
}

resource "aws_secretsmanager_secret_version" "app_config" {
  secret_id     = aws_secretsmanager_secret.app_config.id
  secret_string = var.secrets_json
}
