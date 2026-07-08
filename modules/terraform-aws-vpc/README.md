# terraform-aws-vpc

Creates a 3-tier VPC — public, private, and database subnets across 2
availability zones — with an Internet Gateway, NAT gateway(s), route
tables/associations, and an RDS DB subnet group.

## Usage

```hcl
module "vpc" {
  source = "../modules/terraform-aws-vpc"

  project_name          = "hotel-bookings"
  environment           = "dev"
  common_tags           = { Project = "hotel-bookings", Environment = "dev" }
  cidr_block            = "10.0.0.0/16"
  public_subnet_cidrs   = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs  = ["10.0.11.0/24", "10.0.12.0/24"]
  database_subnet_cidrs = ["10.0.21.0/24", "10.0.22.0/24"]
  single_nat_gateway    = true
}
```

## Inputs

| Name                  | Type       | Default       | Description                                |
|--------------------------|------------|-----------------|-----------------------------------------------|
| `project_name`              | string      | –                | Used in resource naming and tags.                |
| `environment`                 | string      | –                | e.g. `dev`, `prod`.                                  |
| `common_tags`                   | map(any)     | –                | Tags applied to every resource.                          |
| `cidr_block`                       | string      | `10.0.0.0/16`      | VPC CIDR block.                                              |
| `public_subnet_cidrs`                 | list(any)     | –                | Exactly 2 CIDRs (ALB tier).                                     |
| `private_subnet_cidrs`                  | list(any)     | –                | Exactly 2 CIDRs (ECS/Fargate tier).                                |
| `database_subnet_cidrs`                    | list(any)     | –                | Exactly 2 CIDRs (RDS tier).                                           |
| `single_nat_gateway`                          | bool          | `true`             | `true` = 1 shared NAT, `false` = 1 NAT per AZ.                          |

## Outputs

| Name                          | Description                       |
|----------------------------------|---------------------------------------|
| `vpc_id`, `vpc_cidr`                 | VPC identifiers.                          |
| `azs`                                  | AZ names used, in order.                     |
| `public_subnet_ids` / `private_subnet_ids` / `database_subnet_ids` | Subnet ID lists. |
| `database_subnet_group_name`             | Name of the RDS DB subnet group.                 |
| `igw_id`                                    | ID of the Internet Gateway.                          |
