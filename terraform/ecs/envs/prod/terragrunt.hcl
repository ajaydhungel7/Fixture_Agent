terraform {
  source = "../.."
}

remote_state {
  backend = "s3"
  config = {
    bucket       = "bedrock-terraform-backend"
    key          = "agent/ecs/prod/terraform.tfstate"
    region       = "us-east-1"
  }
}

inputs = {
  project_name = "rubyrana-football-prod"
  aws_region   = "us-east-1"
  desired_count = 2
}
