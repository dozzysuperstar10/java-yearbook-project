output "ec2_public_ip" {
  description = "Public IP address of EC2"
  value       = aws_instance.devops_server.public_ip
}

output "ec2_instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.devops_server.id
}
