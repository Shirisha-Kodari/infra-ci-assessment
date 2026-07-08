## project ##

variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "common_tags" {
  type    = map(any)
  default = {}
}

## alb ##

variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(any)
}

variable "alb_sg_id" {
  type = string
}

variable "container_port" {
  type = number
}

variable "certificate_arn" {
  description = "ACM certificate ARN. Leave empty for HTTP-only (dev)."
  type        = string
  default     = ""
}

variable "alb_tags" {
  type    = map(any)
  default = {}
}
