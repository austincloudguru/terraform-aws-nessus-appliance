output "image_id" {
  value = module.nessus-appliance.image_id
}

# output "instance_public_ip" {
#   value = module.nessus-appliance.instance_public_ip
# }

output "asg_name" {
  value = module.nessus-appliance.asg_name
}

output "aws_region" {
  value = var.region
}
