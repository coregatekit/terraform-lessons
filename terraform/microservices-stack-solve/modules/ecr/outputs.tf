output "repository_urls" {
  value       = { for k, v in aws_ecr_repository.services : k => v.repository_url }
  description = "Map of service name -> ECR repository URL, e.g. for use in CI/CD push steps"
}

output "repository_arns" {
  value = { for k, v in aws_ecr_repository.services : k => v.arn }
}
