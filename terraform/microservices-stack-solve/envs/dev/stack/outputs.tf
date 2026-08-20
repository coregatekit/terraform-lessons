output "api_endpoint" {
  value = module.api_gateway.api_endpoint
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "rds_endpoint" {
  value = module.rds.endpoint
}

output "redis_endpoint" {
  value = module.redis.endpoint
}

output "s3_bucket" {
  value = module.s3_assets.bucket_id
}

output "ecr_repository_urls" {
  value = module.ecr.repository_urls
}

output "alerts_topic_arn" {
  value = module.monitoring.sns_topic_arn
}
