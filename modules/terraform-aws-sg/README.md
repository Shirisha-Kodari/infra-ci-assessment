# terraform-aws-sg

Creates a single, bare security group (no ingress rules) with an
allow-all egress rule. Instantiated once per tier (`alb`, `ecs`, `rds`)
from the root module, which then attaches its own
`aws_security_group_rule` resources on top — keeping ingress chaining
(ALB → ECS → RDS) explicit and readable at the root, never buried inside
a module.

## Usage

```hcl
module "sg" {
  count  = length(var.sg_names)
  source = "../modules/terraform-aws-sg"

  project        = var.project_name
  environment    = var.environment
  sg_name        = var.sg_names[count.index]        # "alb" | "ecs" | "rds"
  sg_description = var.sg_descriptions[count.index]
  vpc_id         = module.vpc.vpc_id
}
```

## Inputs

| Name             | Type       | Default | Description                            |
|-------------------|------------|---------|--------------------------------------------|
| `project`           | string      | –       | Used to build the SG name and default tags.    |
| `environment`         | string      | –       | e.g. `dev`, `prod`.                                |
| `sg_name`               | string      | –       | Tier identifier, e.g. `alb`, `ecs`, `rds`.            |
| `sg_description`          | string      | –       | Human-readable SG description.                          |
| `vpc_id`                    | string      | –       | VPC the SG is created in.                                  |

## Outputs

| Name     | Description             |
|-----------|---------------------------|
| `sg_id`     | ID of the created security group. |
