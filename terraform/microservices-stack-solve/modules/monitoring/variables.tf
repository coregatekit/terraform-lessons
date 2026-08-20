variable "environment" {
  type = string
}

variable "eks_cluster_name" {
  type = string
}

variable "rds_instance_id" {
  type = string
}

variable "redis_cluster_id" {
  type = string
}

variable "alert_email" {
  type        = string
  description = "Email to notify on alarms. Leave blank to skip the email subscription (e.g. wire Slack/PagerDuty separately instead)."
  default     = ""
}

variable "rds_cpu_threshold" {
  type    = number
  default = 80
}

variable "rds_free_storage_threshold_bytes" {
  type        = number
  default     = 2000000000 # 2 GB
  description = "Alarm fires if free storage drops below this"
}

variable "redis_cpu_threshold" {
  type    = number
  default = 75
}
