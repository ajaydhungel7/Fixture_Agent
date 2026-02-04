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

variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "CIDR block for the VPC"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
  description = "CIDR blocks for public subnets (2)"
}

variable "private_subnet_cidrs" {
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
  description = "CIDR blocks for private subnets (2)"
}

variable "container_port" {
  type        = number
  default     = 8080
}

variable "desired_count" {
  type        = number
  default     = 1
}

variable "task_cpu" {
  type        = number
  default     = 512
}

variable "task_memory" {
  type        = number
  default     = 1024
}

variable "secrets_json" {
  type        = string
  default     = "{}"
  description = "JSON payload for Secrets Manager (prod config)"
}

variable "secret_keys" {
  type        = list(string)
  default     = ["ANTHROPIC_API_KEY", "FOOTBALL_DATA_API_KEY"]
  description = "JSON keys to inject as ECS secrets"
}
