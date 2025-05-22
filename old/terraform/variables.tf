variable "region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "instance_count" {
  description = "Number of EC2 instances to create"
  type        = number
  default     = 1
}

variable "env_config" {
  description = "Environment-specific configurations"
  type = map(object({
    instance_type = string
    ports         = list(number)
  }))
  default = {
    dev = {
      instance_type = "t2.micro"
      ports         = [22, 80, 8080]
    }
    test = {
      instance_type = "t2.small"
      ports         = [22, 80, 8090]
    }
    prod = {
      instance_type = "t3a.medium"
      ports         = [22, 80, 443]
    }
  }
}