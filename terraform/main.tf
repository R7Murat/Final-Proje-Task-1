terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

data "aws_ami" "latest_amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*-kernel-6.1-x86_64"]
  }
}

resource "aws_instance" "app_server" {
  ami           = data.aws_ami.latest_amazon_linux.id
  instance_type = var.env_config[terraform.workspace].instance_type
  count         = var.instance_count
  key_name      = "${terraform.workspace}-key"

  tags = {
    Name        = "${terraform.workspace}-server-${count.index}"
    Environment = terraform.workspace
    ManagedBy   = "Terraform"
  }

  vpc_security_group_ids = [aws_security_group.app_sg.id]
}

resource "aws_security_group" "app_sg" {
  name        = "${terraform.workspace}-sg"
  description = "Security group for ${terraform.workspace} environment"

  dynamic "ingress" {
    for_each = var.env_config[terraform.workspace].ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}