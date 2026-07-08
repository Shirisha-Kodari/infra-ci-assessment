locals {
  resource_name = "${var.project_name}-${var.environment}" # hotel-bookings-dev
  az_names      = slice(data.aws_availability_zones.available.names, 0, length(var.public_subnet_cidrs))
}
