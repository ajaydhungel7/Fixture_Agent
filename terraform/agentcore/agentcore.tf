resource "aws_bedrockagentcore_agent_runtime" "agentcore_runtime" {
  agent_runtime_name = var.agentcore_runtime_name
  role_arn           = aws_iam_role.agentcore_runtime.arn

  environment_variables = var.secrets_manager_secret_name == null ? {} : {
    SECRETS_MANAGER_SECRET_ID = aws_secretsmanager_secret.app_config[0].name
  }

  agent_runtime_artifact {
    container_configuration {
      container_uri = "${aws_ecr_repository.app.repository_url}:latest"
    }
  }

  network_configuration {
    network_mode = local.agentcore_network_mode_effective
  }
}

