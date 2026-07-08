## project ##

variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "common_tags" {
  type = map(any)
}

## vpc ##

variable "cidr_block" {
  type    = string
  default = "10.0.0.0/16"
}

variable "instance_tenancy" {
  type    = string
  default = "default"
}

variable "enable_dns_hostnames" {
  type    = bool
  default = true
}

variable "vpc_tags" {
  type    = map(any)
  default = {}
}

## igw ##

variable "igw_tags" {
  type    = map(any)
  default = {}
}

## public subnet (ALB tier) ##

variable "public_subnet_cidrs" {
  type = list(any)
  validation {
    condition     = length(var.public_subnet_cidrs) == 2
    error_message = "please provide 2 valid public subnet CIDR"
  }
}

variable "public_subnet_cidr_tags" {
  type    = map(any)
  default = {}
}

variable "map_public_ip_on_launch" {
  type    = bool
  default = true
}

## private subnet (ECS/Fargate tier) ##

variable "private_subnet_cidrs" {
  type = list(any)
  validation {
    condition     = length(var.private_subnet_cidrs) == 2
    error_message = "please provide 2 valid private subnet CIDR"
  }
}

variable "private_subnet_cidr_tags" {
  type    = map(any)
  default = {}
}

## database subnet (RDS tier) ##

variable "database_subnet_cidrs" {
  type = list(any)
  validation {
    condition     = length(var.database_subnet_cidrs) == 2
    error_message = "please provide 2 valid database subnet CIDR"
  }
}

variable "database_subnet_cidr_tags" {
  type    = map(any)
  default = {}
}

## nat gateway ##

variable "nat_gateway_tags" {
  type    = map(any)
  default = {}
}

variable "elastic_ip_tags" {
  type    = map(any)
  default = {}
}

variable "single_nat_gateway" {
  description = "true = one shared NAT (dev/cost saving). false = one NAT per AZ (prod HA)."
  type        = bool
  default     = true
}

## route tables ##

variable "public_route_table_tags" {
  type    = map(any)
  default = {}
}

variable "private_route_table_tags" {
  type    = map(any)
  default = {}
}

variable "database_route_table_tags" {
  type    = map(any)
  default = {}
}

## database subnet group ##

variable "db_subnet_group_tags" {
  type    = map(any)
  default = {}
}
