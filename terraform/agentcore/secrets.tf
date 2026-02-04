resource "aws_secretsmanager_secret" "app_config" {
  count = var.secrets_manager_secret_name == null ? 0 : 1
  name  = var.secrets_manager_secret_name
}
