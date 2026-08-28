data "aws_availability_zones" "available" {}

#random Provider for random ID for unique resourcenames

resource "random_id" "random" {
  byte_length = 2
}

resource "aws_vpc" "N10135_test_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.cloud_env}-N10135_test_vpc"
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_internet_gateway" "N10135_test_igw" {
  vpc_id = aws_vpc.N10135_test_vpc.id
  tags = {
    Name = "${var.cloud_env}-N10135_test_igw"
  }
}

resource "aws_route_table" "N10135_public_rt" {
  vpc_id = aws_vpc.N10135_test_vpc.id
  tags = {
    Name = "${var.cloud_env}-N10135_public_rt"
  }
}

resource "aws_route" "N10135_public_rt_route" {
  route_table_id         = aws_route_table.N10135_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.N10135_test_igw.id
}

resource "aws_default_route_table" "N10135_private_rt" {
  default_route_table_id = aws_vpc.N10135_test_vpc.default_route_table_id
  tags = {
    Name = "${var.cloud_env}-N10135_private_rt"
  }
}

resource "aws_subnet" "N10135_public_subnet" {
  count = 2
  //count                   = length(var.public_cidrs)
  vpc_id                  = aws_vpc.N10135_test_vpc.id
  cidr_block              = var.public_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.cloud_env}-N10135_public_subnet-${count.index + 1}"
  }
}

resource "aws_subnet" "N10135_private_subnet" {
  count = 2
  //count                   = length(var.private_cidrs)
  vpc_id                  = aws_vpc.N10135_test_vpc.id
  cidr_block              = var.private_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false
  tags = {
    Name = "${var.cloud_env}-N10135_private_subnet-${count.index + 1}"
  }
}

resource "aws_route_table_association" "N10135_public_rt_assoc" {
  count          = 2
  subnet_id      = aws_subnet.N10135_public_subnet[count.index].id
  route_table_id = aws_route_table.N10135_public_rt.id
}

resource "aws_route_table_association" "N10135_private_rt_assoc" {
  count          = 2
  subnet_id      = aws_subnet.N10135_private_subnet[count.index].id
  route_table_id = aws_default_route_table.N10135_private_rt.id
}

resource "aws_security_group" "N10135_test_sg" {
  name        = "${var.cloud_env}-N10135_test_sg"
  description = "Security group for public instances"
  vpc_id      = aws_vpc.N10135_test_vpc.id

  # Dynamic Egress Rules

  dynamic "egress" {
    for_each = var.security_group_rules.egress
    content {
      description = egress.value.description
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }

  # Dynamic Ingress Rules

  dynamic "ingress" {
    for_each = var.security_group_rules.ingress
    content {
      description = ingress.value.description
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }
}

resource "aws_eip" "N10135_eip" {
  count    = var.add_eip ? var.instance_count : 0
  instance = element(aws_instance.ec2_instance.*.id, count.index)
  domain   = "vpc"
}

output "vpc_id" {
  value = aws_vpc.N10135_test_vpc.id
}