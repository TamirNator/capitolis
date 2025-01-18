# resource "aws_lb" "alb" {
#   name               = "multi-app-alb"
#   load_balancer_type = "application"
#   security_groups    = [aws_security_group.lb_sg.id]
#   subnets            = module.vpc.public_subnets
#   enable_deletion_protection = false
#   tags = {
#     Name = "multi-app-alb"
#   }
# }

# resource "aws_security_group" "lb_sg" {
#   name        = "example-lb-sg"
#   description = "Security group for ALB"
#   vpc_id      = module.vpc.vpc_id

#   # Allow HTTP traffic from anywhere to the ALB
#   ingress {
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   # Allow all outbound traffic from the ALB
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "example-lb-sg"
#   }
# }

# resource "aws_lb_target_group" "app_tg" {
#   name        = "app-target-group"
#   port        = 5001
#   protocol    = "HTTP"
#   vpc_id      = module.vpc.vpc_id
#   health_check {
#     path                = "/health"
#     interval            = 30
#     timeout             = 5
#     healthy_threshold   = 3
#     unhealthy_threshold = 2
#   }
# }

# resource "aws_lb_target_group" "jenkins_tg" {
#   name     = "jenkins-target-group"
#   port     = 8080
#   protocol = "HTTP"
#   vpc_id   = module.vpc.vpc_id

#   health_check {
#     path                = "/login"
#     interval            = 30
#     timeout             = 5
#     healthy_threshold   = 3
#     unhealthy_threshold = 2
#   }
# }

# resource "aws_lb_listener" "http_listener" {
#   load_balancer_arn = aws_lb.alb.arn
#   port              = 80
#   protocol          = "HTTP"

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.app_tg.arn
#   }
# }

# resource "aws_lb_listener_rule" "app_rule" {
#   listener_arn = aws_lb_listener.http_listener.arn
#   priority     = 100

#   condition {
#     path_pattern {
#       values = ["/movies/*"]
#     }
#   }

#   action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.app_tg.arn
#   }
# }

# resource "aws_lb_listener_rule" "jenkins_rule" {
#   listener_arn = aws_lb_listener.http_listener.arn
#   priority     = 200

#   condition {
#     path_pattern {
#       values = ["/jenkins/*"]
#     }
#   }

#   action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.jenkins_tg.arn
#   }
# }