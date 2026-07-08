resource "aws_security_group" "main" {
  name        = var.sg_name # e.g. alb, ecs, rds
  description = var.sg_description
  vpc_id      = var.vpc_id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(
    var.sg_tags,
    local.common_tags,
    {
      Name = local.sg_name
    }
  )
}
