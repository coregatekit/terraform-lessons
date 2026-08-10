# MiniStack Local Testing — Cheat Sheet (Lesson 2)

## Docker / MiniStack Commands

| Command | Description |
| --- | --- |
| `docker compose up -d` | Start MiniStack container in background |
| `docker compose ps` | Check container status/health |
| `docker compose down` | Stop and remove MiniStack container |
| `curl http://localhost:4566/_ministack/health` | Health check endpoint |

## AWS CLI Setup (fake credentials, MiniStack doesn't validate them)

```bash
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=us-east-1
```

## AWS CLI Verification Commands

| Command | Description |
| --- | --- |
| `aws --endpoint-url=http://localhost:4566 s3 ls` | List S3 buckets |
| `aws --endpoint-url=http://localhost:4566 iam list-roles` | List IAM roles |
| `aws --endpoint-url=http://localhost:4566 sqs list-queues` | List SQS queues |
| `aws --endpoint-url=http://localhost:4566 sts get-caller-identity` | Verify STS endpoint works |

## Terraform Provider Config for MiniStack

```hcl​
provider "aws" {
  region                      = "us-east-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  s3_use_path_style           = true

  endpoints {
    s3  = "<http://localhost:4566>"
    iam = "<http://localhost:4566>"
    sqs = "<http://localhost:4566>"
    sts = "<http://localhost:4566>"
    # ⚠️ ต้องเพิ่มทุก service ที่ใช้ใน .tf ไม่งั้น provider
    # จะ fallback ไปยิง AWS จริงแบบเงียบๆ (403 InvalidClientTokenId)
  }
}
```

## Key Concepts / Gotchas

- **Every AWS service used in `.tf`** (both `resource` and `data` blocks) must have a matching entry in `endpoints {}` — missing one causes a silent fallback to real AWS, not an obvious error.
- MiniStack is a free, open-source LocalStack alternative — drop-in compatible endpoint (`localhost:4566`), no account/auth token required for basic services (S3, IAM, SQS, STS).
- Most services are **in-memory** — data is lost on container restart unless `PERSIST_STATE=1` is set.
- IAM policy logic is stored but **not strictly enforced** — good for testing syntax/workflow, not security correctness.
- Don't mount `docker.sock` unless you specifically need real containers (RDS/ECS) — unnecessary privilege escalation risk for basic S3/IAM/SQS work.

## SQS vs RabbitMQ vs Kafka (quick reference)

| | SQS | RabbitMQ | Kafka |
| --- | --- | --- | --- |
| Message after consume | Deleted | Deleted (ack) | Retained (replayable) |
| Multi-consumer re-read | No | No | Yes (per consumer group) |
| Best for | Simple task queue | Task queue + routing | Event streaming |
