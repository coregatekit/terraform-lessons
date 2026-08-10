resource "aws_elasticache_subnet_group" "main" {
  name       = "${var.environment}-redis-subnet-group"
  subnet_ids = var.private_data_subnet_ids
}

resource "aws_elasticache_cluster" "main" {
  cluster_id           = "${var.environment}-redis"
  engine               = "redis"
  engine_version        = "7.1"
  node_type            = var.node_type
  num_cache_nodes      = var.num_cache_nodes
  port                 = 6379
  parameter_group_name = "default.redis7"

  subnet_group_name = aws_elasticache_subnet_group.main.name
  security_group_ids = [var.security_group_id]

  tags = {
    Environment = var.environment
  }
}
