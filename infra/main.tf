## db_port is computed once, here, from var.db_engine, and fed to both the
## SG rule (ECS -> RDS) below and the rds module itself. This removes the
## drift risk where the SG rule's hardcoded port and the RDS engine's actual
## port were two independent values that could silently fall out of sync if
## the engine was ever switched.
## (see locals.tf)

## ---------------------------------------------------------------------------
## network
## ---------------------------------------------------------------------------
## NOTE: source is a local relative path so `terraform init` never depends
## on external repo access during CI/review. Each module also lives in its
## own repo (see modules/<name>/README.md) — switch to the commented
## git:: line and pin ?ref= to a tag once those repos are ready to be
## consumed remotely.

module "vpc" {
  # source = "../modules/terraform-aws-vpc"
  source = "git::https://github.com/Shirisha-Kodari/terraform-aws-vpc.git?ref=main"

  project_name           = var.project_name
  environment            = var.environment
  common_tags            = var.common_tags
  cidr_block             = var.cidr_block
  public_subnet_cidrs    = var.public_subnet_cidrs
  private_subnet_cidrs   = var.private_subnet_cidrs
  database_subnet_cidrs  = var.database_subnet_cidrs
  single_nat_gateway     = var.single_nat_gateway
}

## ---------------------------------------------------------------------------
## security groups — sg_names index reference: 0 = alb, 1 = ecs, 2 = rds
## ---------------------------------------------------------------------------

module "sg" {
  count = length(var.sg_names)

  # source = "../modules/terraform-aws-sg"
  source = "git::https://github.com/Shirisha-Kodari/terraform-aws-sg.git?ref=main"

  project        = var.project_name
  environment    = var.environment
  sg_name        = var.sg_names[count.index]
  sg_description = var.sg_descriptions[count.index]
  vpc_id         = module.vpc.vpc_id
}

## ---------------------------------------------------------------------------
## security group rules — chained by security group, never by CIDR, for
## anything past the ALB
## ---------------------------------------------------------------------------

resource "aws_security_group_rule" "alb_http_from_internet" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.sg[0].sg_id
}

resource "aws_security_group_rule" "alb_https_from_internet" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.sg[0].sg_id
}

resource "aws_security_group_rule" "ecs_from_alb" {
  type                     = "ingress"
  from_port                = var.container_port
  to_port                  = var.container_port
  protocol                 = "tcp"
  source_security_group_id = module.sg[0].sg_id
  security_group_id        = module.sg[1].sg_id
}

resource "aws_security_group_rule" "rds_from_ecs" {
  type                     = "ingress"
  from_port                = local.db_port
  to_port                  = local.db_port
  protocol                 = "tcp"
  source_security_group_id = module.sg[1].sg_id
  security_group_id        = module.sg[2].sg_id
}

## ---------------------------------------------------------------------------
## alb
## ---------------------------------------------------------------------------

module "alb" {
  # source = "../modules/terraform-aws-alb"
  source = "git::https://github.com/Shirisha-Kodari/terraform-aws-alb.git?ref=main"

  project_name      = var.project_name
  environment       = var.environment
  common_tags       = var.common_tags
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  alb_sg_id         = module.sg[0].sg_id
  container_port    = var.container_port
  certificate_arn   = var.certificate_arn
}

## ---------------------------------------------------------------------------
## rds
## ---------------------------------------------------------------------------

module "rds" {
  # source = "../modules/terraform-aws-rds"
  source = "git::https://github.com/Shirisha-Kodari/terraform-aws-rds.git?ref=main"

  project_name = var.project_name
  environment  = var.environment
  common_tags  = var.common_tags

  database_subnet_group_name = module.vpc.database_subnet_group_name
  rds_sg_id                  = module.sg[2].sg_id

  engine          = var.db_engine
  engine_version  = var.db_engine_version
  db_name         = var.db_name
  master_username = var.master_username

  instance_class          = var.instance_class
  allocated_storage       = var.allocated_storage
  max_allocated_storage   = var.max_allocated_storage
  multi_az                = var.multi_az
  backup_retention_period = var.backup_retention_period
  deletion_protection     = var.deletion_protection
  monitoring_interval     = var.monitoring_interval
  alarm_sns_topic_arn     = var.alarm_sns_topic_arn
}

## ---------------------------------------------------------------------------
## ecs
## ---------------------------------------------------------------------------

module "ecs" {
  # source = "../modules/terraform-aws-ecs"
  source = "git::https://github.com/Shirisha-Kodari/terraform-aws-ecs.git?ref=main"

  project_name = var.project_name
  environment  = var.environment
  common_tags  = var.common_tags

  private_subnet_ids = module.vpc.private_subnet_ids
  ecs_sg_id          = module.sg[1].sg_id
  target_group_arn   = module.alb.target_group_arn

  container_image = var.container_image
  container_port  = var.container_port
  task_cpu        = var.task_cpu
  task_memory     = var.task_memory
  desired_count   = var.desired_count
  min_capacity    = var.min_capacity
  max_capacity    = var.max_capacity

  db_secret_arn = module.rds.secret_arn
  db_host       = module.rds.db_address
  db_port       = module.rds.db_port
  db_name       = var.db_name
}
