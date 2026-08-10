# =========================================================
# Internal Network Load Balancer — sits in front of EKS.
#
# NOTE: In a real cluster, the AWS Load Balancer Controller
# (installed via Helm inside Kubernetes, not Terraform) usually
# creates and manages this NLB automatically when you create a
# Kubernetes Service of type LoadBalancer / Ingress. This
# Terraform-managed NLB is a simplified stand-in so the network
# path is fully declared here for teaching purposes — in
# production you'd typically either:
#   (a) let the LB Controller own it, and only reference its
#       ARN here via a data source, or
#   (b) use TargetGroupBinding CRDs to bind K8s services to a
#       Terraform-managed target group like this one.
# =========================================================
resource "aws_lb" "internal" {
  name               = "${var.environment}-internal-nlb"
  internal           = true
  load_balancer_type = "network"
  subnets            = var.private_app_subnet_ids

  tags = {
    Environment = var.environment
  }
}

resource "aws_lb_target_group" "services" {
  name        = "${var.environment}-eks-services-tg"
  port        = 80
  protocol    = "TCP"
  vpc_id      = var.vpc_id
  target_type = "ip" # pods register their IPs directly (typical for EKS)

  health_check {
    protocol = "TCP"
  }

  tags = {
    Environment = var.environment
  }
}

resource "aws_lb_listener" "services" {
  load_balancer_arn = aws_lb.internal.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.services.arn
  }
}

# =========================================================
# VPC Link — lets API Gateway reach the private NLB without
# traversing the public internet
# =========================================================
resource "aws_apigatewayv2_vpc_link" "main" {
  name               = "${var.environment}-vpc-link"
  security_group_ids = [var.eks_nodes_security_group_id]
  subnet_ids         = var.private_app_subnet_ids

  tags = {
    Environment = var.environment
  }
}

# =========================================================
# HTTP API — single public entry point for all requests
# =========================================================
resource "aws_apigatewayv2_api" "main" {
  name          = "${var.environment}-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "eks_services" {
  api_id             = aws_apigatewayv2_api.main.id
  integration_type   = "HTTP_PROXY"
  integration_uri    = aws_lb_listener.services.arn
  integration_method = "ANY"
  connection_type    = "VPC_LINK"
  connection_id      = aws_apigatewayv2_vpc_link.main.id
}

# Catch-all route — each microservice owns its own path prefix
# (e.g. /orders/*, /payments/*, /users/*, /notifications/*),
# and routing between them happens inside the cluster (ingress
# path-based routing), not here.
resource "aws_apigatewayv2_route" "catch_all" {
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "ANY /{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.eks_services.id}"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.main.id
  name        = "$default"
  auto_deploy = true
}
