resource "aws_s3_bucket" "aws_recon" {
  bucket        = "${var.aws_recon_base_name}-${random_id.aws_recon.hex}-${data.aws_iam_account_alias.current.id}"
  acl           = "private"
  force_destroy = true

  lifecycle_rule {
    id      = "expire-after-${var.retention_period}-days"
    enabled = true

    expiration {
      days = var.retention_period
    }
  }
}

resource "random_id" "aws_recon" {
  byte_length = 6
}

data "aws_iam_account_alias" "current" {}
