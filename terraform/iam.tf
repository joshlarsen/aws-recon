#
# IAM policies and roles for ECS and CloudWatch execution
#
resource "aws_iam_role" "aws_recon_role" {
  name               = local.aws_recon_task_role_name
  assume_role_policy = data.aws_iam_policy_document.aws_recon_task_execution_assume_role_policy.json
}

data "aws_iam_policy_document" "aws_recon_task_execution_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = [
        "ecs.amazonaws.com",
        "ecs-tasks.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role_policy_attachment" "aws_recon_task_execution" {
  role       = aws_iam_role.aws_recon_role.name
  policy_arn = data.aws_iam_policy.aws_recon_task_execution.arn
}

resource "aws_iam_role_policy" "aws_recon" {
  name = local.bucket_write_policy_name
  role = aws_iam_role.aws_recon_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "${var.aws_recon_base_name}-bucket-write"
    Statement = [
      {
        Sid    = "AWSReconS3PutObject"
        Effect = "Allow"
        Action = "s3:PutObject"
        Resource = [
          "${aws_s3_bucket.aws_recon.arn}/*"
        ]
      }
    ]
  })
}

data "aws_iam_policy" "aws_recon_task_execution" {
  arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_iam_role" "ecs_task_execution" {
  name               = local.ecs_task_execution_role_name
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_assume_role_policy.json

  tags = {
    Name = local.ecs_task_execution_role_name
  }
}

data "aws_iam_policy_document" "ecs_task_execution_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# ECS task execution
resource "aws_iam_policy" "ecs_task_execution" {
  name   = local.ecs_task_execution_policy_name
  policy = data.aws_iam_policy.ecs_task_execution.policy
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = aws_iam_policy.ecs_task_execution.arn
}

data "aws_iam_policy" "ecs_task_execution" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# CloudWatch Events
resource "aws_iam_role" "cw_events" {
  name               = local.cw_events_role_name
  assume_role_policy = data.aws_iam_policy_document.cw_events_assume_role_policy.json
}

data "aws_iam_policy_document" "cw_events_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "cw_events" {
  name   = local.cw_events_policy_name
  policy = data.aws_iam_policy.cw_events.policy
}

resource "aws_iam_role_policy_attachment" "cw_events" {
  role       = aws_iam_role.cw_events.name
  policy_arn = aws_iam_policy.cw_events.arn
}

data "aws_iam_policy" "cw_events" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceEventsRole"
}

locals {
  bucket_write_policy_name       = "${var.aws_recon_base_name}-bucket-write-policy"
  ecs_task_execution_role_name   = "${var.aws_recon_base_name}-ecs-task-execution-role"
  ecs_task_execution_policy_name = "${var.aws_recon_base_name}-ecs-task-execution-policy"
  cw_events_policy_name          = "${var.aws_recon_base_name}-cw-events-policy"
  cw_events_role_name            = "${var.aws_recon_base_name}-cw-events-role"
  aws_recon_task_role_name       = "${var.aws_recon_base_name}-exec-role"
}
