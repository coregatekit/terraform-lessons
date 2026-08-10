output "api_endpoint" {
  value = aws_apigatewayv2_api.main.api_endpoint
}

output "target_group_arn" {
  value       = aws_lb_target_group.services.arn
  description = "Bind this to your K8s Services via TargetGroupBinding CRD"
}
