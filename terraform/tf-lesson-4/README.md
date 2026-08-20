# Ephemeral CI/CD Workflow — Cheat Sheet (Lesson 4)

## Core Concept

```
PR opened → CI: apply → test → destroy (ALWAYS, even if apply/test fails)
```

The hard part isn't writing the workflow — it's guaranteeing `destroy` runs even when
an earlier step fails, so no resources (or state) are ever left orphaned.

---

## State / Environment Isolation per PR

Use Terragrunt's `get_env()` to inject a unique environment name per PR so concurrent
PRs don't collide:

```hcl
# envs/ci/terragrunt.hcl
include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../modules/app-storage"
}

inputs = {
  environment = get_env("PR_ENVIRONMENT", "local-test")
  bucket_name = "myapp"
}
```

---

## GitHub Actions Workflow Skeleton

```yaml
name: Ephemeral Test Environment

on:
  pull_request:
    branches: [main]

concurrency:
  group: ephemeral-${{ github.event.pull_request.number }}
  cancel-in-progress: true

jobs:
  ephemeral-test:
    runs-on: ubuntu-latest

    services:
      ministack:
        image: ministackorg/ministack:latest
        ports:
          - 4566:4566
        options: >-
          --health-cmd "curl -f http://localhost:4566/_ministack/health"
          --health-interval 5s
          --health-timeout 3s
          --health-retries 5

    env:
      AWS_ACCESS_KEY_ID: test
      AWS_SECRET_ACCESS_KEY: test
      AWS_DEFAULT_REGION: us-east-1
      PR_ENVIRONMENT: pr-${{ github.event.pull_request.number }}

    steps:
      - uses: actions/checkout@v4

      - uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: "1.9.0"

      - name: Setup Terragrunt
        run: |
          curl -Lo terragrunt https://github.com/gruntwork-io/terragrunt/releases/latest/download/terragrunt_linux_amd64
          chmod +x terragrunt
          sudo mv terragrunt /usr/local/bin/

      - name: Terragrunt Apply
        working-directory: envs/ci
        run: terragrunt apply -auto-approve

      - name: Run integration tests
        working-directory: envs/ci
        run: |
          aws --endpoint-url=http://localhost:4566 s3 ls | grep "myapp-${PR_ENVIRONMENT}"
          aws --endpoint-url=http://localhost:4566 sqs list-queues | grep "app-tasks-${PR_ENVIRONMENT}"

      - name: Terragrunt Destroy (always cleanup)
        if: always()
        working-directory: envs/ci
        run: terragrunt destroy -auto-approve
```

Save to: `.github/workflows/ephemeral-env.yml`

---

## Key Mechanisms

| Feature | Why it matters |
| --- | --- |
| `if: always()` | Forces the destroy step to run regardless of whether prior steps passed or failed. Without this, a failed test = permanently orphaned resources. |
| `services:` block | GitHub Actions native way to run a sidecar container (MiniStack) alongside the job — no manual `docker run`/networking setup needed; reachable at `localhost:<port>`. |
| `concurrency:` group | Prevents two workflow runs for the same PR from racing each other (e.g. a new push while an old run is still applying). |
| `PR_ENVIRONMENT` env var | Gives each PR its own isolated environment/resource names, avoiding collisions when multiple PRs run CI simultaneously. |

---

## Plan-Gate Pattern (safer apply)

Instead of applying directly, save a plan first so what gets approved is exactly
what gets applied:

```yaml
- name: Terragrunt Plan (gate before apply)
  working-directory: envs/ci
  run: terragrunt plan -out=tfplan

# Optional: manual approval step here via GitHub Environments + required reviewers

- name: Terragrunt Apply from saved plan
  working-directory: envs/ci
  run: terragrunt apply tfplan
```

---

## Production Guardrails (beyond this lab)

- **`timeout-minutes:`** at the job level — prevents a hung workflow (e.g. unresponsive
  emulator/service) from running indefinitely.
- **OIDC instead of static credentials** — for real AWS accounts, don't store
  `AWS_ACCESS_KEY_ID`/`SECRET` as static GitHub Secrets. Use
  [OIDC federation](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect)
  so GitHub Actions requests short-lived, scoped credentials from AWS per run —
  reduces blast radius if a token leaks.
- **Cost/budget alerts** — real cloud spend guardrails so a stuck ephemeral env
  doesn't silently rack up charges.
