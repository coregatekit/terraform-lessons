terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region                      = "us-east-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  s3_use_path_style           = true

  endpoints {
    s3 = "http://localhost:4566"
    iam = "http://localhost:4566"
    sqs = "http://localhost:4566"
    sts = "http://localhost:4566"
  }
}

resource "aws_s3_bucket" "demo" {
  bucket = "${var.bucket_name}-${var.environment}"

  tags = {
    Environment = var.environment
    ManagedBy    = "terraform"
  }
}

resource "aws_sqs_queue" "task_queue" {
  name = "app-tasks-${var.environment}"
}

data "aws_caller_identity" "current" {}
