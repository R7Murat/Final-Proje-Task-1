output "instance_public_ips" {
  description = "Public IP addresses of created instances"
  value       = aws_instance.app_server[*].public_ip
}

output "security_group_id" {
  description = "Security Group ID"
  value       = aws_security_group.app_sg.id
}