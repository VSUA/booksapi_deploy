resource "aws_ecs_cluster" "main_cluster" {
  name = var.cluster_name
}

//data "aws_iam_role" "example" {
//  name = "DatadogAWSIntegrationRole"
//}

resource "aws_ecs_task_definition" "service" {
  family = "service"
  cpu = 256
  memory = 1024
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  //execution_role_arn = data.aws_iam_role.example.arn

  container_definitions = jsonencode([
    {
      name      = "first"
      image     = "vsua/booksapi:latest"
      cpu       = 128
      memory    = 512
      essential = true
      environment = [
        {name = "ACCESS_KEY", value = var.access_key
        },
        {name = "SECRET_KEY", value = var.secret_key
        },
        {name = "REGION_NAME", value = var.region_name
        }
      ]
      portMappings = [
        {
          containerPort = 5000
          hostPort      = 5000
        }
      ]
    },
    {
      name = "datadog-agent"
      image = "datadog/agent:latest"
      cpu       = 128
      memory    = 512
      environment = [
        {
          name = "DD_API_KEY",
          value = var.dd_api_key
        },
        {
          name = "ECS_FARGATE",
          value = "true"
        },
        {
          name = "DD_SITE",
          value = "datadoghq.eu"
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
  launch_type = "FARGATE"

//  ordered_placement_strategy {
//    type  = "binpack"
//    field = "cpu"
//  }

  load_balancer {
    target_group_arn = aws_lb_target_group.cluster-tg.arn
    container_name   = "first"
    container_port   = 5000
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
    from_port        = 5000
    to_port          = 5000
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
  port     = 5000
  protocol = "HTTP"
  target_type = "ip"
  vpc_id   = var.vpc_id
  health_check {
    enabled = false
  }
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
  port = 5000
}