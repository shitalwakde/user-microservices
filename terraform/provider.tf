terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.55"  # Tested with AWS Provider 4.x
    }
  }

  # Optional: Remote state storage (uncomment to use)
  # backend "s3" {
  #   bucket         = "your-terraform-state-bucket"
  #   key            = "user-microservice/terraform.tfstate"
  #   region         = "us-east-1"
  #   dynamodb_table = "terraform-locks"  # For state locking
  #   encrypt        = true
  # }
}

provider "aws" {
  region = var.aws_region  # From variables.tf

  # Default tags for all resources
  default_tags {
    tags = {
      Project     = var.app_name
      Environment = terraform.workspace  # Useful when using workspaces
      ManagedBy   = "Terraform"
      Owner       = "DevOps-Team"
    }
  }
}

# Optional: Additional AWS provider for SSM Parameters in another region
provider "aws" {
  alias  = "ssm_west"
  region = "us-west-2"  # For multi-region SSM parameters
}