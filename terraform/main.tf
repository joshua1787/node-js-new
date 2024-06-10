provider "aws" {
  region = "eu-north-1" 
  access_key = "AWS_ACCESS_KEY_ID"
  secret_key = "AWS_SECRET_ACCESS_KEY"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "subnet" {
  count = 2
  vpc_id = vpc-05c06af67cc9f42be
  cidr_block = "10.0.${count}.0/24"
  availability_zone = element(["eu-north-1a", "eu-north-1b"], count.index)
}

resource "aws_security_group" "sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_cluster" "main" {
  name = "hello-world-cluster"
}

resource "aws_ecs_task_definition" "main" {
  family                   = "hello-world-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"

  container_definitions = jsonencode([{
    name      = "hello-world"
    image     = "${aws_ecr_repository.main.repository_url}:latest"
    essential = true
    portMappings = [{
      containerPort = 3000
      hostPort      = 3000
    }]
  }])

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
}

resource "aws_ecs_service" "main" {
  name            = "hello-world-service"
  cluster         = "arn:aws:ecs:eu-north-1:058264184150:cluster/hello-world-cluster"
  task_definition = aws_ecs_task_definition.main.arn
  desired_count   = 1

  launch_type = "FARGATE"

  network_configuration {
    subnets          = ["subnet-0798dbbdbbbe67258"]
    security_groups  = ["sg-093bf0dd8adf0dfae"]
    assign_public_ip = true
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  ]
}

resource "aws_ecr_repository" "main" {
  name = "hello-world-repo"
}

