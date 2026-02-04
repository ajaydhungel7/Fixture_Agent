terraform {
  source = "../.."
}

remote_state {
  backend = "s3"
  config = {
    bucket       = "bedrock-terraform-backend"
    key          = "agent/ecs/staging/terraform.tfstate"
    region       = "us-east-1"
  }
}

inputs = {
  project_name = "rubyrana-football-staging"
  aws_region   = "us-east-1"
}
