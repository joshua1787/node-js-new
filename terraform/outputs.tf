output "vpc_id" {
  value = aws_vpc.main.id
}

output "subnet_ids" {
  value = aws_subnet.subnet[*].id
}

output "security_group_id" {
  value = aws_security_group.sg.id
}

output "ecs_cluster_id" {
  value = aws_ecs_cluster.main.id
}

output "ecs_task_definition_arn" {
  value = aws_ecs_task_definition.main.arn
}

output "ecs_service_name" {
  value = aws_ecs_service.main.name
}

