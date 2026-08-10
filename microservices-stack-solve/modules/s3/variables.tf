variable "environment" {
  type = string
}

variable "bucket_name" {
  type        = string
  description = "Base bucket name — environment will be appended"
}
