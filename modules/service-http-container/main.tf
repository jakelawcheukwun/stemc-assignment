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
