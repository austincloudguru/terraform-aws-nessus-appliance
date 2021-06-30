output "image_id" {
  value = data.aws_ami.this.id
}

output "security_group_id" {
  value       = aws_security_group.this.id
  description = "Security Group ID"
}

output "security_group_arn" {
  value       = aws_security_group.this.arn
  description = "Security Group ARN"
}

output "security_group_name" {
  value       = aws_security_group.this.name
  description = "Security Group name"
}

output "role_arn" {
  value       = aws_iam_role.this.arn
  description = "Role ARN"
}

output "instance_arn" {
  value       = aws_instance.this.arn
  description = "Instance Arn"
}

output "instance_public_ip" {
  value       = aws_instance.this.public_ip
  description = "Instance Public IP Address"
}

output "instance_private_ip" {
  value       = aws_instance.this.private_ip
  description = "Instance Private IP Address"
}
