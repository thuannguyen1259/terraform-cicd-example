terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.0.0"
    }
  }
}

provider "aws" {
  region = "ap-southeast-1" # Singapore
}

# Tạo Security Group cho EC2
resource "aws_security_group" "cicd_sg" {
  name_prefix = "cicd-sg-"

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
    Name = "CICDSG"
  }
}

data "aws_ami" "latest" {
  most_recent = true
  owners      = ["amazon"] # Amazon official AMIs

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"] # Amazon Linux 2023
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Tạo EC2
resource "aws_instance" "cicd_ec2" {
  ami                    = data.aws_ami.latest.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.cicd_sg.id]

  tags = {
    Name = "CICDEC2"
  }
}

# Output public IP của EC2
output "ec2_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.cicd_ec2.public_ip
}
