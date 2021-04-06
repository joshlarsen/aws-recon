variable "aws_recon_base_name" {
  type    = string
  default = "aws-recon"
}

variable "aws_recon_container_name" {
  type    = string
  default = "darkbitio/aws_recon"
}

variable "aws_recon_container_version" {
  type    = string
  default = "latest"
}

variable "aws_regions" {
  type = list(any)
  default = [
    "global",
    # "af-south-1",
    # "ap-east-1",
    # "ap-northeast-1",
    # "ap-northeast-2",
    # "ap-northeast-3",
    # "ap-south-1",
    # "ap-southeast-1",
    # "ap-southeast-2",
    # "ca-central-1",
    # "eu-central-1",
    # "eu-north-1",
    # "eu-south-1",
    # "eu-west-1",
    # "eu-west-2",
    # "eu-west-3",
    # "me-south-1",
    # "sa-east-1",
    "us-east-1",
    "us-east-2",
    "us-west-1",
    "us-west-2",
  ]
}

# must be one of: 0, 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365
variable "retention_period" {
  type    = number
  default = 30
}

variable "schedule_expression" {
  type    = string
  default = "cron(4 * * * ? *)"
}

variable "base_subnet_cidr" {
  type    = string
  default = "10.76.0.0/16"
}
