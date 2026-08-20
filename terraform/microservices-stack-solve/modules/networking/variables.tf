variable "environment" {
  type        = string
  description = "Environment name (dev, staging, prod)"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "azs" {
  type        = list(string)
  description = "Availability zones to spread subnets across"
  default     = ["us-east-1a", "us-east-1b"]
}

# Public subnets: NAT Gateway, internet-facing ALB (if any)
variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.0.0/24", "10.0.1.0/24"]
}

# Private-app subnets: EKS worker nodes
variable "private_app_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.10.0/24", "10.0.11.0/24"]
}

# Private-data subnets: RDS, ElastiCache
variable "private_data_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.20.0/24", "10.0.21.0/24"]
}

# Cost-saving toggle: 1 NAT Gateway shared across AZs (lab/dev) vs 1 per AZ (prod HA)
variable "single_nat_gateway" {
  type        = bool
  description = "Use a single NAT Gateway instead of one per AZ (cheaper, less HA)"
  default     = true
}
