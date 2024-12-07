terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.78.0"
    }
  }
}

provider "aws" {
  # Configuration options
  region     = "eu-west-2"
 # access_key = ""
 # secret_key = ""

}


#VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.project_name}-igw"
  }
}

# Public Subnet
resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index)
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = "${var.project_name}-public-subnet-${count.index + 1}"
  }
}

# Route Table for Public Subnet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

resource "aws_route" "internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Security Group for Backend
resource "aws_security_group" "backend_sg" {
  vpc_id = aws_vpc.main.id
  ingress {
    from_port   = 22
    to_port     = 22
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
    Name = "${var.project_name}-backend-sg"
  }
}

# Security Group for Frontend
resource "aws_security_group" "frontend_sg" {
  vpc_id = aws_vpc.main.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
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
    Name = "${var.project_name}-frontend-sg"
  }
}


# Backend Servers
resource "aws_instance" "backend-server" {
  count         = 4
  ami           = var.ami_id
  instance_type = var.backend_instance_type
  subnet_id     = aws_subnet.public[0].id
  vpc_security_group_ids = [aws_security_group.backend_sg.id
  ]
 
  tags = {
    Name = "${var.project_name}-backendserver-${count.index + 1}"
  }
}

# Frontend Servers
resource "aws_instance" "frontend-server" {
  count         = 2
  ami           = var.ami_id
  instance_type = var.frontend_instance_type
  subnet_id     = aws_subnet.public[1].id
  vpc_security_group_ids = [aws_security_group.frontend_sg.id]
 
  tags = {
    Name = "${var.project_name}-frontendserver-${count.index + 1}"
  }
}
# Data source for availability zones
data "aws_availability_zones" "available" {}


#IAM User
resource "aws_iam_user" "admin-user" {
  name =  "BOB2"
  tags = {
    description = "CIO"
  } 
}

# Create S3 Bucket

resource "aws_s3_bucket" "pato-bucket" {
  bucket = "pato-terraform-bucket"

  tags = {
    Name        = "patobucket"
    Environment = "Dev"
  }
}
