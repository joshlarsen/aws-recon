output "aws_recon_ecs_cluster" {
  value = aws_ecs_cluster.aws_recon.name
}

output "aws_recon_ecs_scheduled_task" {
  value = aws_cloudwatch_event_rule.default.name
}

output "aws_recon_s3_bucket" {
  value = aws_s3_bucket.aws_recon.bucket
}

output "aws_recon_task_manual_run_command" {
  value = "\nOne-off task run command:\n\naws ecs run-task --task-definition ${aws_ecs_task_definition.aws_recon_task.family} --cluster ${aws_ecs_cluster.aws_recon.name} --launch-type FARGATE --network-configuration \"awsvpcConfiguration={subnets=[${aws_subnet.subnet.id}],securityGroups=[${aws_security_group.sg.id}],assignPublicIp=ENABLED}\"\n"
}
