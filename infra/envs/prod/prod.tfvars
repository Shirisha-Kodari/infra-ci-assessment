environment  = "prod"
project_name = "hotel-bookings"
aws_region   = "us-east-1"

common_tags = {
  Project     = "hotel-bookings"
  Environment = "prod"
  Terraform   = "true"
}

## networking - prod gets one NAT gateway per AZ for HA ##
cidr_block             = "10.1.0.0/16"
public_subnet_cidrs    = ["10.1.1.0/24", "10.1.2.0/24"]
private_subnet_cidrs   = ["10.1.11.0/24", "10.1.12.0/24"]
database_subnet_cidrs  = ["10.1.21.0/24", "10.1.22.0/24"]
single_nat_gateway     = false

## alb / container ##
container_port  = 80
certificate_arn = "" # set to a real ACM cert ARN before going live
container_image = "public.ecr.aws/nginx/nginx:1.27"

## ecs sizing - prod runs more, bigger tasks ##
task_cpu      = 512
task_memory   = 1024
desired_count = 2
min_capacity  = 2
max_capacity  = 6

## rds - prod sizing, longer retention, protected ##
db_engine               = "postgres"
db_engine_version       = "16.4"
db_name                 = "bookings"
master_username         = "app_admin"
instance_class          = "db.r6g.large"
allocated_storage       = 100
max_allocated_storage   = 500
multi_az                = true
backup_retention_period = 30
deletion_protection     = true
monitoring_interval     = 60 # enhanced monitoring on

alarm_sns_topic_arn = null # set to a real SNS topic ARN for on-call alerting
