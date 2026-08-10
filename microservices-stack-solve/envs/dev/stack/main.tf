# =========================================================
# 1. Networking — foundation everything else depends on
# =========================================================
module "networking" {
  source      = "../../../modules/networking"
  environment = var.environment
}

# =========================================================
# 2. EKS — runs the 4 microservices
# =========================================================
module "eks" {
  source                  = "../../../modules/eks"
  environment              = var.environment
  vpc_id                   = module.networking.vpc_id
  private_app_subnet_ids   = module.networking.private_app_subnet_ids
}

# =========================================================
# 3. RDS — Postgres, only reachable from EKS nodes
# =========================================================
module "rds" {
  source                    = "../../../modules/rds"
  environment                = var.environment
  private_data_subnet_ids    = module.networking.private_data_subnet_ids
  security_group_id          = module.networking.rds_security_group_id
  db_password                = var.db_password
}

# =========================================================
# 4. Redis — session/cache store, only reachable from EKS nodes
# =========================================================
module "redis" {
  source                    = "../../../modules/redis"
  environment                = var.environment
  private_data_subnet_ids    = module.networking.private_data_subnet_ids
  security_group_id          = module.networking.redis_security_group_id
}

# =========================================================
# 5. S3 — assets & documents, private, outside the VPC
# =========================================================
module "s3_assets" {
  source      = "../../../modules/s3"
  environment = var.environment
  bucket_name = "myapp-assets"
}

# =========================================================
# 6. API Gateway — single public entry point, VPC-linked to EKS
# =========================================================
module "api_gateway" {
  source                        = "../../../modules/api-gateway"
  environment                    = var.environment
  vpc_id                         = module.networking.vpc_id
  private_app_subnet_ids         = module.networking.private_app_subnet_ids
  eks_nodes_security_group_id    = module.networking.eks_nodes_security_group_id
}

# =========================================================
# 7. ECR — image registry, one repo per microservice
# =========================================================
module "ecr" {
  source      = "../../../modules/ecr"
  environment = var.environment
}

# =========================================================
# 8. Monitoring — CloudWatch Container Insights + alarms + SNS
# =========================================================
module "monitoring" {
  source            = "../../../modules/monitoring"
  environment       = var.environment
  eks_cluster_name  = module.eks.cluster_name
  rds_instance_id   = module.rds.instance_id
  redis_cluster_id  = "${var.environment}-redis"
  alert_email       = var.alert_email
}
