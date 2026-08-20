output "sns_topic_arn" {
  value       = aws_sns_topic.alerts.arn
  description = "Subscribe additional channels (Slack, PagerDuty) to this topic as needed"
}
