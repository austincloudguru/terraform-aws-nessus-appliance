locals {
  product_code = var.preauth ? "4m4uvwtrl5t872c56wb131ttw" : "8fn69npzmbzcs4blc4583jd0y"
}

#-----------------------------------
# Create the Security Group
#-----------------------------------
resource "aws_security_group" "this" {
  name        = var.name
  description = join(" ", ["Security Group for", var.name])
  vpc_id      = var.vpc_id
  tags = merge(
    {
      "Name" = var.name
    },
    var.tags
  )
  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

resource "aws_security_group_rule" "this_ingress" {
  for_each          = var.security_group_ingress
  security_group_id = aws_security_group.this.id
  type              = "ingress"
  description       = lookup(each.value, "description", null)
  from_port         = lookup(each.value, "from_port", null)
  protocol          = lookup(each.value, "protocol", null)
  to_port           = lookup(each.value, "to_port", null)
  self              = lookup(each.value, "self", null) == false ? null : each.value.self
  cidr_blocks       = lookup(each.value, "cidr_blocks", null)
}

resource "aws_security_group_rule" "this_egress" {
  for_each          = var.security_group_egress
  security_group_id = aws_security_group.this.id
  type              = "egress"
  from_port         = lookup(each.value, "from_port", null)
  protocol          = lookup(each.value, "protocol", null)
  to_port           = lookup(each.value, "to_port", null)
  self              = lookup(each.value, "self", null) == false ? null : each.value.self
  cidr_blocks       = lookup(each.value, "cidr_blocks", null)
}

#-----------------------------------
# Create the Instance Profile
#-----------------------------------
resource "aws_iam_instance_profile" "this" {
  name = var.name
  role = aws_iam_role.this.name
}

resource "aws_iam_role" "this" {
  name               = var.name
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  tags = merge(
    {
      "Name" = var.name
    },
    var.tags
  )
  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

resource "aws_iam_role_policy_attachment" "ec2_readonly" {
  role       = aws_iam_role.this.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = [
        "ec2.amazonaws.com"
      ]
    }
  }
}

#-----------------------------------
# Lookup the Nessus AMI
#-----------------------------------
data "aws_ami" "this" {
  most_recent = true
  owners      = ["aws-marketplace"]

  filter {
    name   = "product-code"
    values = [local.product_code]
  }
}

#------------------------------------------------------------------------------
# Create the Userdata Templates
#------------------------------------------------------------------------------
# data "template_file" "user_data" {
#   count    = var.preauth ? 1 : 0
#   template = <<EOF
# {
# "name": "$${nessus_name}",
# "key":"$${nessus_key}",
# "iam_role": "$${nessus_iam}",
# nessus_proxy == "" ? "" : "\"proxy\": \"$${nessus_proxy}\""
# nessus_proxy_port == "" ? "" : "\"proxy_port\": \"$${nessus_proxy_port}\""
# }
# EOF


#   vars = {
#     nessus_name = var.nessus_scanner_name
#     nessus_key = var.nessus_key
#     nessus_iam = aws_iam_role.this.name
#     nessus_proxy = var.nessus_proxy
#     nessus_proxy_port = var.nessus_proxy_port
#   }
# }

data "template_file" "user_data" {
  count    = var.preauth ? 1 : 0
  template = <<EOF
{
"name": "$${nessus_name}",
"key":"$${nessus_key}",
"iam_role": "$${nessus_iam}",
$${nessus_proxy}
$${nessus_proxy_port}
}
EOF


  vars = {
    nessus_name       = var.nessus_scanner_name
    nessus_key        = var.nessus_key
    nessus_iam        = aws_iam_role.this.name
    nessus_proxy      = var.nessus_proxy == "" ? "" : "\"proxy\": \"{{ var.nessus_proxy }}\""
    nessus_proxy_port = var.nessus_proxy_port == "" ? "" : "\"proxy_port\": \"{{ var.nessus_proxy_port }}\""
  }
}


# #!/bin/bash
# yum update -y
# service nessusd stop
# /opt/nessus/sbin/nessuscli managed link --key=<insert-key-here> --cloud
# service nessusd start



#-----------------------------------
# Deploy Nessus Instance
#-----------------------------------
resource "aws_instance" "this" {
  ami                    = data.aws_ami.this.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  iam_instance_profile   = aws_iam_instance_profile.this.name
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.this.id]
  user_data              = var.preauth ? data.template_file.user_data[0].rendered : ""
  tags = merge(
    {
      "Name" = var.name
    },
    var.tags
  )
  volume_tags = merge(
    {
      "Name" = var.name
    },
    var.tags
  )
  lifecycle {
    ignore_changes = [volume_tags]
  }
}
