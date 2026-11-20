output "instance_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.idevify_ec2.public_ip
}

output "instance_public_dns" {
  description = "Public DNS of the EC2 instance"
  value       = aws_instance.idevify_ec2.public_dns
}

output "application_url" {
  description = "Application URL"
  value       = "http://${aws_instance.idevify_ec2.public_ip}"
}

output "ssh_command" {
  description = "SSH connection command"
  value       = "ssh -i idevify-ec2-key.pem ubuntu@${aws_instance.idevify_ec2.public_ip}"
}
