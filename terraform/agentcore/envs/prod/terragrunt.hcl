terraform {
  source = "../.."
}

remote_state {
  backend = "s3"
  config = {
    bucket       = "bedrock-terraform-backend"
    key          = "agent/agentcore/prod/terraform.tfstate"
    region       = "us-east-1"
  }
}

inputs = {
  project_name             = "rubyrana-football-prod"
  aws_region               = "us-east-1"
  agentcore_runtime_name   = "rubyrana_football_runtime_prod"
  agentcore_network_mode   = "PUBLIC"
  agentcore_use_vpc         = false
  secrets_manager_secret_name = "rubyrana-football-prod-agentcore-config"
}
