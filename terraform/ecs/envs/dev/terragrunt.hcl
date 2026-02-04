terraform {
  source = "../.."
}

remote_state {
  backend = "s3"
  config = {
    bucket       = "bedrock-terraform-backend"
    key          = "agent/ecs/dev/terraform.tfstate"
    region       = "us-east-1"
  }
}

inputs = {
  project_name = "rubyrana-football-dev"
  aws_region   = "us-east-1"
}
