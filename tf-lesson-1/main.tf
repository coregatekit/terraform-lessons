terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-southeast-1"
}

resource "aws_s3_bucket" "demo" {
  bucket = "${var.bucket_name}-${var.environment}"

  tags = {
    Environment = var.environment
    MangedBy    = "terraform"
  }
}

data "aws_caller_identity" "current" {}
