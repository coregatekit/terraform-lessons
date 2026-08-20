# =========================================================
# SNS topic — single fan-out point for all alarms below.
# Wire this to Slack/PagerDuty/Opsgenie via an additional
# subscription resource if email isn't your primary channel.
# =========================================================
resource "aws_sns_topic" "alerts" {
  name = "${var.environment}-infra-alerts"
}

resource "aws_sns_topic_subscription" "email" {
  count     = var.alert_email != "" ? 1 : 0
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

# =========================================================
# EKS Container Insights — cluster/pod/node level CPU, memory,
# and log collection. This installs the CloudWatch observability
# EKS add-on (runs as a DaemonSet inside the cluster).
# =========================================================
resource "aws_eks_addon" "container_insights" {
  cluster_name = var.eks_cluster_name
  addon_name   = "amazon-cloudwatch-observability"

  # If the cluster/nodegroup isn't fully ready yet, let the addon
  # retry rather than failing the whole apply outright.
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
}

# =========================================================
# RDS Alarms
# =========================================================
resource "aws_cloudwatch_metric_alarm" "rds_cpu" {
  alarm_name          = "${var.environment}-rds-high-cpu"
  namespace           = "AWS/RDS"
  metric_name         = "CPUUtilization"
  statistic           = "Average"
  period              = 300
  evaluation_periods  = 3
  threshold           = var.rds_cpu_threshold
  comparison_operator = "GreaterThanThreshold"
  alarm_description   = "RDS CPU above ${var.rds_cpu_threshold}% for 15 minutes"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  ok_actions          = [aws_sns_topic.alerts.arn]

  dimensions = {
    DBInstanceIdentifier = var.rds_instance_id
  }
}

resource "aws_cloudwatch_metric_alarm" "rds_low_storage" {
  alarm_name          = "${var.environment}-rds-low-storage"
  namespace           = "AWS/RDS"
  metric_name         = "FreeStorageSpace"
  statistic           = "Average"
  period              = 300
  evaluation_periods  = 1
  threshold           = var.rds_free_storage_threshold_bytes
  comparison_operator = "LessThanThreshold"
  alarm_description   = "RDS free storage below threshold — risk of running out of disk"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  ok_actions          = [aws_sns_topic.alerts.arn]

  dimensions = {
    DBInstanceIdentifier = var.rds_instance_id
  }
}

# =========================================================
# Redis (ElastiCache) Alarms
# =========================================================
resource "aws_cloudwatch_metric_alarm" "redis_cpu" {
  alarm_name          = "${var.environment}-redis-high-cpu"
  namespace           = "AWS/ElastiCache"
  metric_name         = "CPUUtilization"
  statistic           = "Average"
  period              = 300
  evaluation_periods  = 3
  threshold           = var.redis_cpu_threshold
  comparison_operator = "GreaterThanThreshold"
  alarm_description   = "Redis CPU above ${var.redis_cpu_threshold}% for 15 minutes"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  ok_actions          = [aws_sns_topic.alerts.arn]

  dimensions = {
    CacheClusterId = var.redis_cluster_id
  }
}

# Note: for app-level dashboards (per-microservice request rate,
# latency, error rate), most teams pair this CloudWatch baseline
# with Prometheus + Grafana deployed inside the cluster via Helm
# (kube-prometheus-stack) — that's Kubernetes-layer tooling, not
# something Terraform manages directly. See README for the
# suggested split of responsibilities.
