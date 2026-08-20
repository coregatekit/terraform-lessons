# One repository per microservice — keeps IAM/lifecycle policy scoped
# per-service instead of one shared repo with path prefixes.
resource "aws_ecr_repository" "services" {
  for_each = toset(var.service_names)

  name                 = "${var.environment}/${each.value}"
  image_tag_mutability = var.image_tag_mutability

  image_scanning_configuration {
    scan_on_push = true # flags known CVEs in pushed images automatically
  }

  tags = {
    Environment = var.environment
    Service     = each.value
  }
}

# Lifecycle policy: expire old untagged images + cap tagged image count,
# so the registry doesn't grow unbounded (and cost) forever.
resource "aws_ecr_lifecycle_policy" "services" {
  for_each   = aws_ecr_repository.services
  repository = each.value.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Expire untagged images after ${var.untagged_image_expiry_days} days"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = var.untagged_image_expiry_days
        }
        action = { type = "expire" }
      },
      {
        rulePriority = 2
        description  = "Keep only the last ${var.max_tagged_images_to_keep} tagged images"
        selection = {
          tagStatus     = "tagged"
          tagPatternList = ["*"]
          countType     = "imageCountMoreThan"
          countNumber   = var.max_tagged_images_to_keep
        }
        action = { type = "expire" }
      }
    ]
  })
}

# Note: EKS node group role already has AmazonEC2ContainerRegistryReadOnly
# attached (see modules/eks/main.tf), so nodes can pull from these repos
# with no extra wiring. For CI/CD to *push* images, create a separate IAM
# role/user with ecr:PutImage etc. scoped to these repository ARNs.
