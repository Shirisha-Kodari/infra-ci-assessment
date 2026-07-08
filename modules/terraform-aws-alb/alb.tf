## alb ##

resource "aws_lb" "this" {
  name               = "${local.resource_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = var.environment == "prod"
  drop_invalid_header_fields = true

  tags = merge(
    var.common_tags,
    var.alb_tags,
    {
      Name = "${local.resource_name}-alb"
    }
  )
}

## target group ##

resource "aws_lb_target_group" "app" {
  name        = "${local.resource_name}-tg"
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip" # required for Fargate

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
    matcher             = "200"
  }

  # Grace period so ECS can drain in-flight requests before a target is
  # deregistered on deploys/scale-in.
  deregistration_delay = 30

  tags = merge(var.common_tags, var.alb_tags)
}

## http listener ##

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  dynamic "default_action" {
    for_each = local.use_https ? [1] : []
    content {
      type = "redirect"
      redirect {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  }

  dynamic "default_action" {
    for_each = local.use_https ? [] : [1]
    content {
      type             = "forward"
      target_group_arn = aws_lb_target_group.app.arn
    }
  }
}

## https listener (only when a cert is supplied) ##

resource "aws_lb_listener" "https" {
  count             = local.use_https ? 1 : 0
  load_balancer_arn = aws_lb.this.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}
