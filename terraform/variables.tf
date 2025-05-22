variable "aws_ami_ids" {
  type = map(string)
  default = {
    dev    = "ami-0953476d60561c955"
    prod   = "ami-0953476d60561c955"
    test   = "ami-0953476d60561c955"
    default = "ami-0953476d60561c955"
  }
  description = "Environment-specific AMI IDs"
}

variable "security_group_ports" {
  type = map(list(number))
  default = {
    default = [80, 22]
    dev     = [80, 443, 22, 8080, 3306]
    test    = [80, 443, 22, 8080, 8090]
    prod    = [22, 80, 443, 8080, 3000]
  }
  description = "Allowed ports per environment"
}

variable "ec2_instance_types" {
  type = map(string)
  default = {
    dev     = "t2.micro"
    test    = "t2.small"
    prod    = "t3a.medium"
    default = "t2.micro"
  }
  description = "EC2 instance types per environment"
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
  description = "AWS region for deployment"
}

variable "ssh_key_name" {
  type    = string
  default = "N.Virginia"
  description = "SSH key pair name"
}

variable "instance_count" {
  type    = number
  default = 1
  description = "Number of EC2 instances to deploy"
}