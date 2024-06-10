provider "aws" {
  region = "eu-north-1"  
  access_key = "AWS_ACCESS_KEY_ID"
  secret_key = "AWS_SECRET_ACCESS_KEY"
}

resource "aws_ecs_cluster" "main" {
  name = "hello-world-cluster"
}

resource "aws_ecs_task_definition" "main" {
  family                = "hello-world-task"
  container_definitions = jsonencode([{
    name      = "hello-world-container"
    image     = "joshuaveeraiah/my-node-app:latest"
    essential = true
    portMappings = [{
      containerPort = 3000
      protocol      = "tcp"
    }]
  }])

  cpu    = "256"  //  CPU at task level
  memory = "512"  // Memory at task level

  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  execution_role_arn = aws_iam_role.execution_role.arn

  tags = {
    Name = "hello-world-task"
  }
}

resource "aws_ecs_service" "main" {
  name            = "hello-world-service"
  cluster         = "arn:aws:ecs:eu-north-1:058264184150:cluster/hello-world-cluster"
  task_definition = aws_ecs_task_definition.main.arn
  desired_count   = 1

  network_configuration {
    subnets         = ["subnet-0798dbbdbbbe67258"] 
    security_groups = ["sg-093bf0dd8adf0dfae"] 
  }

  depends_on = [aws_ecs_task_definition.main]

  tags = {
    Name = "hello-world-service"
  }
}

resource "aws_security_group" "ecs_security_group" {
  name        = "ecs_security_group"
  description = "Security group for ECS tasks"
  vpc_id      = "vpc-05c06af67cc9f42be" 

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

  tags = {
    Name = "ecs_security_group"
  }
}

resource "aws_iam_role" "execution_role" {
  name               = "ecsTaskExecutionRole"
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }]
  })
}

