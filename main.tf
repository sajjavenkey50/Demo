variable "type" {
  type = string
}
resource "tls_private_key" "myprvtkey" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = local.key_name
  public_key = tls_private_key.myprvtkey.public_key_openssh
}
resource "aws_vpc" "vpc" {
  cidr_block           = local.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${local.environment}-vpc"
    Environment = local.environment
  }
}
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "terraformigw"
  }
}
resource "aws_route_table" "table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "NewRoute"
  }
}
resource "aws_main_route_table_association" "a" {
  vpc_id         = aws_vpc.vpc.id
  route_table_id = aws_route_table.table.id
}
resource "aws_subnet" "public" {
  count                   = length(local.availability_zones)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(local.vpc_cidr, 8, count.index)
  availability_zone       = element(local.availability_zones, count.index)
  map_public_ip_on_launch = true

  tags = {
    "Name" = "Public subnet - ${element(local.availability_zones, count.index)}"
  }
}


resource "aws_security_group" "Instance_SG" {
  name        = "Instance-SG"
  description = "Traffic to EC2"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "instances aws security group"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    #cidr_blocks = [aws_vpc.main.cidr_block]
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "instances aws security group"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Instance-SG"
  }
}
resource "aws_instance" "awsvm" {
  count                  = 1
  ami                    = local.ami
  key_name               = aws_key_pair.generated_key.id
  instance_type          = local.type
  vpc_security_group_ids = [aws_security_group.Instance_SG.id]
  subnet_id              = aws_subnet.public[count.index].id
  tags = merge(
    {
      "Name" = length(aws_subnet.public[0].id) > 1 || local.use_num_suffix ? format("%s${local.num_suffix_format}", "TestEnv", count.index + 1) : "TestEnv"
    }
  )
}

locals {
  environment                = "test"
  availability_zones         = ["us-west-2a", "us-west-2b", "us-west-2c"]
  region                     = "us-west-2"
  vpc_cidr                   = "10.0.0.0/16"
  instance_count             = 1
  ami                        = "ami-02701bcdc5509e57b"
  key_name                   = "ec2ssh"
  use_num_suffix             = false
  num_suffix_format          = "-%d"
  type                       = var.type != "" ? var.type : "t2.micro"
  idle_timeout               = 60
  enable_deletion_protection = false
}
