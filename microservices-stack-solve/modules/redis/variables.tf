variable "environment" {
  type = string
}

variable "private_data_subnet_ids" {
  type = list(string)
}

variable "security_group_id" {
  type = string
}

variable "node_type" {
  type    = string
  default = "cache.t3.micro"
}

variable "num_cache_nodes" {
  type    = number
  default = 1 # bump to 2+ with a replication group for prod HA
}
