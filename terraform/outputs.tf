output "instance_public_ips" {
  description = "Deployed EC2 instances' public IP addresses"
  value       = aws_instance.devops_project_instance[*].public_ip
}

output "security_group_id" {
  description = "Created security group ID"
  value       = aws_security_group.devops-project-sg.id
}

# Optional: Add more outputs as needed
output "instance_ids" {
  description = "Deployed EC2 instance IDs"
  value       = aws_instance.devops_project_instance[*].id
}