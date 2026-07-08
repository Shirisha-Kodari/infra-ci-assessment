locals {
  sg_name = "${var.project}-${var.environment}-${var.sg_name}"
  common_tags = {
    Project     = var.project
    Environment = var.environment
    Terraform   = "true"
  }
}
