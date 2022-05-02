resource "aws_lb" "http_lb" {
  name               = "http-lb"
  internal           = false
  load_balancer_type = "network"
  subnets            = var.designated_subnets

  enable_deletion_protection = false
  
  
}

# need a listener tf resource
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.http_lb.arn
  port              = "80"
  protocol          = "TCP"
  # certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"
  # alpn_policy       = "HTTP2Preferred"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.front_end.arn
  }
}

# TODO: could be missing IAM role for ECS LB etcetc as shown in AWS docs


# here's the attachment tf resource
resource "aws_lb_target_group_attachment" "front_end" {
  target_group_arn = aws_lb_target_group.front_end.arn
  # we need the full ARN; container ID doesn't work
  # TODO: fetch ECS container ID through tf data source object
  target_id        = "9b84b52f-278f-46c1-a343-b557627a1de9"
  port             = 80
}

# Alternative: target the ENI IP of the ECS container
resource "aws_lb_target_group" "front_end" {
  name        = "http-lb-tg"
  port        = 80
  protocol    = "TCP"
  # for IP target option
  # target_type = "ip"
  vpc_id      = var.vpc_id
}


resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Allow http inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    description      = "http from anywhere"
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
  }

  tags = {
    Name = "allow_tls"
  }
}


resource "aws_ecs_service" "http-service" {
  name            = "http-service"
  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.http-server.arn
  desired_count = 1
  
  capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight = 1

  }
  network_configuration {
    subnets = var.designated_subnets
    security_groups = [aws_security_group.allow_http.id]
    assign_public_ip = true
  }

  deployment_maximum_percent         = 100
  deployment_minimum_healthy_percent = 0
}


resource "aws_ecs_task_definition" "http-server" {
  family = "http-server"
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  runtime_platform {
    operating_system_family = "LINUX"
  }
  cpu = 256
  memory = 512
  container_definitions = <<EOF
[
  {
    "name": "fargate-app", 
    "image": "public.ecr.aws/docker/library/httpd:latest",
    "cpu": 256,
    "memory": 512,
    "portMappings": [
        {
            "containerPort": 80, 
            "hostPort": 80, 
            "protocol": "tcp"
        }
    ], 
    "essential": true, 
    "entryPoint": [
        "sh",
        "-c"
    ], 
    "command": [
        "/bin/sh -e -c \"echo '<html> <head> <title>Stemcell DevOps Exam Interview</title><style>body {margin-top: 40px;} </style> </head><body> <div style=text-align:center><p><imgsrc=https://www.stemcell.com/media/catalog/product/cache/06791c9e0f2753b9a10ba615e0766c72/s/t/stemcell-519x291_1.png></p> <h1>STEMCELL DevOps ExamInterview</h1><h2>Congrats! You have passed the STEMCELL DevOps Engeering testexamination.</h2><p></p><p></p><p><strong>Please copy all code used and mail to <ahref=jag.jandoo@stemcell.com>jag.jandoo@stemcell.com</a> for next steps.</strong></p></div></body></html>' > /usr/local/apache2/htdocs/index.html && httpd-foreground\""
    ]
}
]
EOF
}
