variable "environment" {
  type = string
}

variable "db_password" {
  type      = string
  sensitive = true
  default   = "change-me-in-real-use" # dev-only convenience; use Secrets Manager for real environments
}

variable "alert_email" {
  type        = string
  description = "Email to receive CloudWatch alarm notifications. Leave blank to skip the subscription."
  default     = ""
}
