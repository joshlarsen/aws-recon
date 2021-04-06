
# Create a VPC
resource "aws_vpc" "vpc" {
  cidr_block = local.cidr_block
  tags = {
    Name = "${var.aws_recon_base_name}-${random_id.aws_recon.hex}"
  }
}

# Create subnet
resource "aws_subnet" "subnet" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = local.subnet_cidr_block
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "${var.aws_recon_base_name}-${random_id.aws_recon.hex}-public"
  }
}

resource "aws_security_group" "sg" {
  name        = "${var.aws_recon_base_name}-${random_id.aws_recon.hex}"
  description = "Allow AWS Recon collection egress"
  vpc_id      = aws_vpc.vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.aws_recon_base_name}-${random_id.aws_recon.hex}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.aws_recon_base_name}-${random_id.aws_recon.hex}"
  }
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.aws_recon_base_name}-${random_id.aws_recon.hex}"
  }
}

resource "aws_route_table_association" "rt_association" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_route_table.rt.id
}

locals {
  cidr_block        = var.base_subnet_cidr
  subnet_cidr_block = cidrsubnet(local.cidr_block, 8, 0)
}

data "aws_region" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}
