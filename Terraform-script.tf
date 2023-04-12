# Provider Configuration
provider "aws" {
  region = "us-east-1"
}

# Remote Backend Configuration
terraform {
  backend "s3" {
    bucket = "3tire-terraform-backend"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}

# VPC Configuration
resource "aws_vpc" "3tire_vpc" {
  cidr_block = "10.0.0.0/16"
}

# Subnet Configuration
resource "aws_subnet" "web_subnet" {
  vpc_id     = aws_vpc.3tire_vpc.id
  cidr_block = "10.0.1.0/24"
  tags = {
    Name = "web"
  }
}

resource "aws_subnet" "app_subnet" {
  vpc_id     = aws_vpc.3tire_vpc.id
  cidr_block = "10.0.2.0/24"
  tags = {
    Name = "app"
  }
}

resource "aws_subnet" "db_subnet" {
  vpc_id     = aws_vpc.3tire_vpc.id
  cidr_block = "10.0.3.0/24"
  tags = {
    Name = "db"
  }
}

# Security Group Configuration
resource "aws_security_group" "3tire_sg" {
  name_prefix = "3tire_sg"
  vpc_id      = aws_vpc.3tire_vpc.id
}

# Web Server Configuration
resource "aws_instance" "web_server" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.web_subnet.id
  vpc_security_group_ids = [
    aws_security_group.3tire_sg.id
  ]
  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install nginx -y
              EOF
}

# App Server Configuration
resource "aws_instance" "app_server" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.app_subnet.id
  vpc_security_group_ids = [
    aws_security_group.3tire_sg.id
  ]
  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install java -y
              EOF
}

# Database Server Configuration
resource "aws_instance" "db_server" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.db_subnet.id
  vpc_security_group_ids = [
    aws_security_group.3tire_sg.id
  ]
  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install mysql -y
              EOF
}
