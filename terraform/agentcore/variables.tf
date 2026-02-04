variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region"
}

variable "project_name" {
  type        = string
  default     = "rubyrana-football"
  description = "Project name prefix"
}

variable "agentcore_use_vpc" {
  type        = bool
  default     = false
  description = "Whether to create and use a VPC for AgentCore"
}

variable "vpc_cidr" {
  type        = string
  default     = "10.1.0.0/16"
  description = "CIDR block for the AgentCore VPC"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  default     = ["10.1.1.0/24", "10.1.2.0/24"]
  description = "CIDR blocks for public subnets (2)"
}

variable "agentcore_runtime_name" {
  type        = string
  default     = "rubyrana-football-runtime"
}

variable "secrets_manager_secret_name" {
  type        = string
  default     = null
  description = "Optional Secrets Manager secret name to create/use for app config"
}

variable "agentcore_network_mode" {
  type        = string
  default     = "PUBLIC"
  description = "AgentCore network mode: PUBLIC or VPC"
}

variable "image_tag" {
  type        = string
  default     = "latest"
  description = "Docker image tag for AgentCore runtime"
}
