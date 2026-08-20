generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "aws" {
  region                      = "us-east-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  s3_use_path_style           = true

  endpoints {
    s3         = "http://localhost:4566"
    iam        = "http://localhost:4566"
    sts        = "http://localhost:4566"
    ec2        = "http://localhost:4566"
    eks        = "http://localhost:4566"
    rds        = "http://localhost:4566"
    elasticache = "http://localhost:4566"
    apigatewayv2 = "http://localhost:4566"
    elasticloadbalancingv2 = "http://localhost:4566"
    ecr        = "http://localhost:4566"
    cloudwatch = "http://localhost:4566"
    logs       = "http://localhost:4566"
    sns        = "http://localhost:4566"
  }
}
EOF
}
