#----------------------------------------
# ターゲットグループ
#----------------------------------------
resource "aws_lb_target_group" "tg_app" {
  name     = "tg-app"
  port     = 80
  protocol = "HTTP"
  target_type = "instance"
  vpc_id   = aws_vpc.app.id

  tags = {
    Name = "tg_app_app1"
  }
}

#----------------------------------------
# ターゲットグループ ALBの紐付け
#----------------------------------------
resource "aws_lb_target_group_attachment" "tg_app" {
  target_group_arn = aws_lb_target_group.tg_app.arn
  target_id        = aws_instance.ec2_app.id
  port             = 80
}

#----------------------------------------
# ALB 本体
#----------------------------------------
resource "aws_lb" "alb_app" {
  name               = "alb-app"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg_app_alb.id]
  subnets            = [
    aws_subnet.pub1.id,
    aws_subnet.pub2.id
  ]

  tags = {
    Name = "alb_app_app1"
  }
}

#----------------------------------------
# ALB リスナー
#----------------------------------------
resource "aws_lb_listener" "forward_app" {
  load_balancer_arn = aws_lb.alb_app.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = aws_acm_certificate_validation.acm_validation.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_app.arn
  }
}