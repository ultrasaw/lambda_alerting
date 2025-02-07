terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.85.0"
    }
  }

  backend "s3" {
    bucket = "prerequisites-lambda-infra"
    key    = "terraform/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Name        = "lambda_alerting_project"
      Purpose     = "infrastructure for setting up alerting with Lambda / SNS"
      Environment = "dev"
    }
  }
}
