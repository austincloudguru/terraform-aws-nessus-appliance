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
