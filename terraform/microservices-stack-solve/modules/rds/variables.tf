variable "environment" {
  type = string
}

variable "private_data_subnet_ids" {
  type = list(string)
}

variable "security_group_id" {
  type = string
}

variable "db_name" {
  type    = string
  default = "appdb"
}

variable "db_username" {
  type    = string
  default = "appadmin"
}

variable "db_password" {
  type        = string
  sensitive   = true
  description = "In real use, source this from AWS Secrets Manager / SSM, never a plain .tfvars"
}

variable "instance_class" {
  type    = string
  default = "db.t3.micro"
}

variable "allocated_storage" {
  type    = number
  default = 20
}

variable "multi_az" {
  type        = bool
  description = "Enable Multi-AZ standby for production HA"
  default     = false
}
