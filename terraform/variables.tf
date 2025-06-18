variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Application name used in resource tags"
  type        = string
  default     = "user-microservice"
}

variable "envs" {
  description = "Environment configurations"
  type = map(object({
    instance_type = string
    instance_count = number
    enable_alb    = bool
  }))
  default = {
    dev = {
      instance_type = "t2.micro"
      instance_count = 1
      enable_alb    = false
    },
    uat = {
      instance_type = "t2.small"
      instance_count = 1
      enable_alb    = false
    },
    prod = {
      instance_type = "t2.medium"
      instance_count = 3  # Auto-scaled
      enable_alb    = true
    }
  }
}

variable "ssh_key_name" {
  description = "Name of existing EC2 key pair for SSH access"
  type        = string
}

variable "db_password" {
  description = "RDS database password"
  type        = string
  sensitive   = true
}