environment  = "dev"
project_name = "hotel-bookings"
aws_region   = "us-east-1"

common_tags = {
  Project     = "hotel-bookings"
  Environment = "dev"
  Terraform   = "true"
}

## networking - dev shares one NAT gateway to save cost ##
cidr_block             = "10.0.0.0/16"
public_subnet_cidrs    = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs   = ["10.0.11.0/24", "10.0.12.0/24"]
database_subnet_cidrs  = ["10.0.21.0/24", "10.0.22.0/24"]
single_nat_gateway     = true

## alb / container ##
container_port  = 80
certificate_arn = "" # HTTP-only in dev
container_image = "public.ecr.aws/nginx/nginx:1.27"

## ecs sizing - dev is small and disposable ##
task_cpu      = 256
task_memory   = 512
desired_count = 1
min_capacity  = 1
max_capacity  = 2

## rds - dev sizing, short retention, no protection ##
db_engine               = "postgres"
db_engine_version       = "16.4"
db_name                 = "bookings"
master_username         = "app_admin"
instance_class          = "db.t4g.micro"
allocated_storage       = 20
max_allocated_storage   = 100
multi_az                = false
backup_retention_period = 3
deletion_protection     = false
monitoring_interval     = 0 # enhanced monitoring disabled in dev

alarm_sns_topic_arn = null
