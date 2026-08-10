variable "environment" {
  type = string
}

variable "service_names" {
  type        = list(string)
  description = "One ECR repository is created per service name"
  default     = ["orders", "payments", "users", "notifications"]
}

variable "image_tag_mutability" {
  type        = string
  description = "MUTABLE allows overwriting a tag (e.g. :latest); IMMUTABLE is safer for prod"
  default     = "IMMUTABLE"
}

variable "untagged_image_expiry_days" {
  type        = number
  description = "Delete untagged images older than N days to control storage cost"
  default     = 14
}

variable "max_tagged_images_to_keep" {
  type    = number
  default = 20
}
