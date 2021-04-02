output "aws_recon_ecs_cluster" {
  value = aws_ecs_cluster.aws_recon.name
}

output "aws_recon_ecs_scheduled_task" {
  value = aws_cloudwatch_event_rule.default.name
}

output "aws_recon_s3_bucket" {
  value = aws_s3_bucket.aws_recon.bucket
}
