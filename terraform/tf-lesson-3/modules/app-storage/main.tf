terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

resource "aws_s3_bucket" "demo" {
  bucket = "${var.bucket_name}-${var.environment}"
}

resource "aws_sqs_queue" "task_queue" {
  name = "app-tasks-${var.environment}"
}

data "aws_caller_identity" "current" {}
