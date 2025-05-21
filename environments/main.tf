terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

module "ec2_cluster" {
  source = "./modules/ec2"
  
  instance_type = local.instance_type
  key_name      = var.key_name
  environment   = local.environment
}

locals {
  environment   = terraform.workspace
  instance_type = lookup({
    dev     = "t2.micro",
    test    = "t2.micro",
    staging = "t2.micro",
    prod    = "t3a.medium"
  }, local.environment, "t2.micro")
}