resource "aws_ecs_cluster" "aws_recon" {
  name               = "${var.aws_recon_base_name}-${random_id.aws_recon.hex}"
  capacity_providers = [local.ecs_task_provider]
}

resource "aws_ecs_task_definition" "aws_recon_task" {
  family                   = "${var.aws_recon_base_name}-${random_id.aws_recon.hex}"
  task_role_arn            = aws_iam_role.aws_recon_role.arn
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  requires_compatibilities = [local.ecs_task_provider]
  network_mode             = "awsvpc"
  cpu                      = 1024
  memory                   = 2048

  container_definitions = jsonencode([
    {
      name             = "${var.aws_recon_base_name}-${random_id.aws_recon.hex}"
      image            = "${var.aws_recon_container_name}:${var.aws_recon_container_version}"
      assign_public_ip = true
      entryPoint = [
        "aws_recon",
        "--verbose",
        "--format",
        "custom",
        "--json-lines",
        "--s3-bucket",
        "${aws_s3_bucket.aws_recon.bucket}:${data.aws_region.current.name}",
        "--regions",
        join(",", var.aws_regions)
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.aws_recon.name,
          awslogs-region        = data.aws_region.current.name,
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

resource "aws_cloudwatch_log_group" "aws_recon" {
  name              = "/ecs/${var.aws_recon_base_name}-${random_id.aws_recon.hex}"
  retention_in_days = var.retention_period
}

locals {
  ecs_task_provider = "FARGATE"
}
