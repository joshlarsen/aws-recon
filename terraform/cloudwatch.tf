# https://www.terraform.io/docs/providers/aws/r/cloudwatch_event_rule.html
resource "aws_cloudwatch_event_rule" "default" {
  name                = "${var.aws_recon_base_name}-${random_id.aws_recon.hex}"
  description         = "AWS Recon scheduled task"
  schedule_expression = var.schedule_expression
}

# https://www.terraform.io/docs/providers/aws/r/cloudwatch_event_target.html
resource "aws_cloudwatch_event_target" "default" {
  target_id = aws_ecs_task_definition.aws_recon_task.id
  arn       = aws_ecs_cluster.aws_recon.arn
  rule      = aws_cloudwatch_event_rule.default.name
  role_arn  = aws_iam_role.cw_events.arn

  ecs_target {
    launch_type         = "FARGATE"
    task_definition_arn = aws_ecs_task_definition.aws_recon_task.arn
    platform_version    = "LATEST"

    network_configuration {
      assign_public_ip = true
      security_groups  = [aws_security_group.sg.id]
      subnets          = [aws_subnet.subnet.id]
    }
  }
}
