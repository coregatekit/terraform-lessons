# Terraform Fundamentals — Cheat Sheet (Lesson 1)

## CLI Lifecycle Commands

| Command | Description |
| --- | --- |
| `terraform init` | Initialize working dir, download provider plugins |
| `terraform validate` | Syntax check (no cloud auth required) |
| `terraform fmt` | Auto-format `.tf` files to canonical style |
| `terraform plan` | Dry-run: show diff between desired vs current state |
| `terraform plan -out=tfplan` | Save plan to file (for deterministic apply in CI) |
| `terraform apply` | Execute plan, provision/update real resources |
| `terraform apply tfplan` | Apply from a saved plan file |
| `terraform apply -auto-approve` | Apply without interactive confirmation |
| `terraform destroy` | Tear down all resources tracked in state |
| `terraform destroy -auto-approve` | Destroy without confirmation |
| `terraform state list` | List all resources tracked in state |
| `terraform state show <addr>` | Show current attributes of a resource |

## HCL Block Types

| Block | Purpose |
| --- | --- |
| `terraform {}` | Meta-config: required providers, backend |
| `provider "aws" {}` | Configure connection to a cloud/service |
| `variable "name" {}` | Declare input parameter |
| `resource "TYPE" "NAME" {}` | Declare a real infra object to create/manage |
| `data "TYPE" "NAME" {}` | Read-only lookup of existing data (no lifecycle) |
| `output "name" {}` | Export a value after apply |
| `locals {}` | Define reusable computed values within a module |

## Key Concepts

- **State file (`terraform.tfstate`)**: JSON mapping of HCL resource address → real cloud resource ID + attributes. Never commit to git; never hand-edit.
- **Local state**: single-user, no CI/CD.
- **Remote state**: shared backend (e.g. S3 + DynamoDB for locking) — required for team/CI use.
- **State locking**: prevents concurrent `apply` from corrupting state.
- **Interpolation**: `"${var.name}-${var.environment}"` or reference directly: `aws_s3_bucket.demo.arn`
- **Provider credential errors** (`No valid credentials source found`) happen on `plan`/`apply` (which call the real API) — not on `validate` (syntax-only, no auth needed).

## Example Snippet

```hcl​
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-southeast-1"
}

variable "environment" {
  type    = string
  default = "dev"
}

resource "aws_s3_bucket" "demo" {
  bucket = "myapp-${var.environment}"
}

data "aws_caller_identity" "current" {}

output "bucket_arn" {
  value = aws_s3_bucket.demo.arn
}
​```
