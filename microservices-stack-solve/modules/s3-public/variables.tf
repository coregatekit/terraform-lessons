variable "environment" {
  type = string
}

variable "bucket_name" {
  type        = string
  description = "Base bucket name. NOTE: S3 bucket names are globally unique across ALL AWS accounts, not just yours — a literal name like \"public\" is almost certainly already taken on real AWS. This module appends the environment automatically to reduce collision risk."
  default     = "public"
}
