# hotel-bookings-infra

Terraform infrastructure for `Internet → ALB → ECS/Fargate → RDS`, with
a `terraform fmt / init / validate / plan` GitHub Actions workflow that
runs on every Pull Request.

## Repository structure

```
.
├── .github/workflows/terraform.yml   # PR-triggered fmt/init/validate/plan
├── infra/                            # root module — this is what you `terraform apply`
│   ├── main.tf                          # wires all 5 modules together
│   ├── locals.tf                        # computed db_port (postgres/mysql)
│   ├── variables.tf                       # every input, with dev-friendly defaults
│   ├── outputs.tf                          # values needed to verify/operate the stack
│   ├── data.tf                              # account/region context (commented — see below)
│   ├── parameter.tf                          # SSM parameter publishing (commented — see below)
│   ├── provider.tf                             # provider + partial S3 backend config
│   └── envs/
│       ├── dev/{backend.tf,dev.tfvars}
│       └── prod/{backend.tf,prod.tfvars}
└── modules/
    ├── terraform-aws-vpc/     # VPC, subnets, NAT, routing, DB subnet group
    ├── terraform-aws-sg/      # bare security group (no rules) per tier
    ├── terraform-aws-alb/     # ALB + target group + HTTP/HTTPS listeners
    ├── terraform-aws-ecs/     # ECS cluster, task def, service, autoscaling
    └── terraform-aws-rds/     # RDS instance, managed master password, alarms
```

Each module is a local relative path (`../modules/terraform-aws-*`) so
`terraform init` never depends on external repo access in CI or during
review. A commented `git::` alternative is kept next to each `source =`
line in `infra/main.tf` for when these are split into their own repos.

## Environments

`dev` and `prod` each get their own `backend.tf` (state isolation) and
`.tfvars` (sizing/retention/protection):

| Setting                  | dev                  | prod                 |
|-----------------------------|------------------------|-------------------------|
| `instance_class`               | `db.t4g.micro`            | `db.r6g.large`             |
| `backup_retention_period`         | `3` days                    | `30` days                    |
| `deletion_protection`                | `false`                        | `true`                          |
| `multi_az`                              | `false`                          | `true`                            |
| NAT gateways                               | 1 shared                          | 1 per AZ                            |

## Local usage

```bash
cd infra
terraform init  -backend-config=envs/dev/backend.tf
terraform plan  -var-file=envs/dev/dev.tfvars
terraform apply -var-file=envs/dev/dev.tfvars   # not required by the assignment
```

## CI: Terraform Plan on Pull Requests

`.github/workflows/terraform.yml` runs on every PR touching `infra/**` or
`modules/**`:

1. **`terraform fmt -check -recursive`** — gates everything else.
2. **`terraform init -backend=false`** — actual AWS deployment isn't
   required, so state is ephemeral per run; no CI-managed backend needed.
3. **`terraform validate`**
4. **`terraform plan -refresh=false`** — run once per environment (`dev`,
   `prod`) via a matrix.
5. The plan is posted **both**:
   - as a sticky PR comment (updates in place on every push), and
   - as a downloadable workflow artifact (`terraform-plan-dev` /
     `terraform-plan-prod`).

Plan-only AWS access is via **OIDC** (`aws-actions/configure-aws-credentials`)
against a read-only IAM role — no long-lived AWS keys are stored in the
repo. Set the repo secret `AWS_ROLE_ARN` to enable it.

## Note on `data.tf` and `parameter.tf`

The assignment states actual AWS deployment is not required and will be
reviewed via `terraform fmt / init / validate / plan -refresh=false`. Two
extra files, `data.tf` and `parameter.tf`, are included but fully
commented out — they weren't asked for in the brief, so they're disabled
by default to keep `plan` output focused on what was requested.

They exist to show how this stack would be extended for a real
deployment: `data.tf` pulls account/region context, and `parameter.tf`
publishes key outputs (VPC ID, subnet IDs, ALB DNS, ECS cluster/service,
RDS endpoint/secret ARN, etc.) to SSM Parameter Store under
`/<project_name>/<environment>/<name>`, so a future "app" or "monitoring"
stack could look them up without needing this stack's remote state.

To enable them: uncomment both files and run `terraform plan` again.
# trigger ci
