resource "aws_instance" "devops_project_instance" {
  ami                  = terraform.workspace != "default" ? lookup(var.aws_ami_ids, terraform.workspace) : data.aws_ami.al2023.id
  instance_type        = var.ec2_instance_types[terraform.workspace]
  count                = var.instance_count
  iam_instance_profile = "EC2FullAccess"
  key_name             = var.ssh_key_name
  vpc_security_group_ids = [aws_security_group.devops-project-sg.id]
  
  tags = {
    Project = "Devops-Proje-Server"
    Name    = "${terraform.workspace}_server"
  }
}

resource "aws_security_group" "devops-project-sg" {
  dynamic "ingress" {
    for_each = lookup(var.security_group_ports, terraform.workspace)
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  # ... diğer ayarlar aynı kalacak ...
}
