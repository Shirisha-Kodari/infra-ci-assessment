locals {
  resource_name = "${var.project_name}-${var.environment}"
  use_https     = var.certificate_arn != ""
}
