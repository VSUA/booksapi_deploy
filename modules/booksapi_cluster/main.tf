resource "aws_ecs_cluster" "main_cluster" {
  name = var.cluster_name
}

resource "aws_ecs_task_definition" "service" {
  family = "service"
  cpu = 128
  memory = 512
  network_mode = "awsvpc"

  container_definitions = jsonencode([
    {
      name      = "first"
      image     = "nginx"
      cpu       = 64
      memory    = 512
      essential = true
      environment = [
        {name = "JUST_VAR", value = "VALUE"}
      ]
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    }
    ]
  )
}

resource "aws_ecs_service" "mongo" {
  name            = "mongodb"
  cluster         = aws_ecs_cluster.main_cluster.id
  task_definition = aws_ecs_task_definition.service.arn
  desired_count   = 3

  ordered_placement_strategy {
    type  = "binpack"
    field = "cpu"
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.cluster-tg.arn
    container_name   = "first"
    container_port   = 80
  }

  network_configuration {
    subnets = var.priv_subnets.*.id
    security_groups = [aws_security_group.http_sg.id]
  }
}

resource "aws_security_group" "http_sg" {
  name        = "http_sg"
  vpc_id      = var.vpc_id

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_lb_target_group" "cluster-tg" {
  name     = "${var.service_name}-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

//.public.*.id
resource "aws_lb" "nginx" {
  name               = "${var.service_name}-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.http_sg.id]
  subnets            = var.pub_subnets.*.id
}

resource "aws_lb_listener" "example" {
  load_balancer_arn = aws_lb.nginx.id

  default_action {
    target_group_arn = aws_lb_target_group.cluster-tg.arn
    type             = "forward"
  }
  port = 80
}