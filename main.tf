locals {
  userdata = templatefile("${path.module}/files//user_data.tpl",
    {
      license            = var.license_type
      key                = var.nessus_key
      name               = var.nessus_scanner_name
      role               = aws_iam_role.this.name
      proxy              = var.nessus_proxy
      proxy_port         = var.nessus_proxy_port
      nessus_credentials = var.nessus_credentials
    }
  )
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

resource "aws_iam_role_policy" "this" {
  name   = var.name
  role   = aws_iam_role.this.id
  policy = data.aws_iam_policy_document.policy.json
}

data "aws_iam_policy_document" "policy" {
  statement {
    effect = "Allow"
    actions = [
      "ec2:Describe*",
      "elasticloadbalancing:Describe*",
      "cloudwatch:ListMetrics",
      "cloudwatch:GetMetricStatistics",
      "cloudwatch:Describe*",
      "autoscaling:Describe*"
    ]
    resources = ["*"]
  }
  dynamic "statement" {
    for_each = var.additional_iam_statements
    content {
      effect    = lookup(statement.value, "effect", null)
      actions   = lookup(statement.value, "actions", null)
      resources = lookup(statement.value, "resources", null)
    }
  }
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
    values = [var.product_code[var.license_type]]
  }
}

#-----------------------------------
# Deploy Nessus Instance
#-----------------------------------
resource "aws_autoscaling_group" "this" {
  name                      = var.name
  min_size                  = 1
  max_size                  = 1
  desired_capacity          = 1
  health_check_type         = "EC2"
  health_check_grace_period = var.health_check_grace_period
  termination_policies      = var.termination_policies
  vpc_zone_identifier       = var.subnet_ids
  launch_configuration      = aws_launch_configuration.this.name
  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = var.name
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = var.tags
    content {
      key                 = tag.value.key
      propagate_at_launch = true
      value               = tag.value.value
    }
  }
}

resource "aws_launch_configuration" "this" {
  name_prefix                 = join("", [var.name, "-"])
  image_id                    = data.aws_ami.this.id
  instance_type               = var.instance_type
  security_groups             = [aws_security_group.this.id]
  iam_instance_profile        = aws_iam_instance_profile.this.name
  key_name                    = var.key_name
  associate_public_ip_address = var.associate_public_ip_address
  user_data                   = local.userdata

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# resource "aws_instance" "this" {
#   ami                    = data.aws_ami.this.id
#   instance_type          = var.instance_type
#   key_name               = var.key_name
#   iam_instance_profile   = aws_iam_instance_profile.this.name
#   subnet_id              = var.subnet_id
#   vpc_security_group_ids = [aws_security_group.this.id]
#   user_data              = local.userdata
#   tags = merge(
#     {
#       "Name" = var.name
#     },
#     var.tags
#   )
#   volume_tags = merge(
#     {
#       "Name" = var.name
#     },
#     var.tags
#   )
#   lifecycle {
#     ignore_changes = [volume_tags]
#   }
# }

#-----------------------------------
# Cloud Connector Instance Profile
#-----------------------------------
resource "aws_iam_role" "tenable-connector" {
  count                = var.cloud_connector ? 1 : 0
  name                 = "tenableio-connector"
  description          = "Tenable.io Cloud Connector Role"
  max_session_duration = 28800
  assume_role_policy   = data.aws_iam_policy_document.tenable-connector-assume-role.json
}

resource "aws_iam_role_policy" "tenable-connector" {
  count  = var.cloud_connector ? 1 : 0
  name   = "tenable-io-connector-policy"
  role   = resource.aws_iam_role.tenable-connector[0].name
  policy = data.aws_iam_policy_document.tenable-connector.json

}

data "aws_iam_policy_document" "tenable-connector-assume-role" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      identifiers = ["arn:aws:iam::012615275169:root"]
      type        = "AWS"
    }
    condition {
      test     = "StringEquals"
      values   = [var.external_id]
      variable = "sts:ExternalId"
    }
  }
}

data "aws_iam_policy_document" "tenable-connector" {
  statement {
    effect = "Allow"
    actions = [
      "ec2:Describe*",
      "ec2:DescribeVpcPeeringConnections",
      "ec2:DescribeVpcs",
      "s3:ListAllMyBuckets",
      "s3:GetObject",
      "s3:GetBucketLocation",
      "cloudtrail:GetTrailStatus",
      "cloudtrail:DescribeTrails",
      "cloudtrail:LookupEvents",
      "cloudtrail:ListTags",
      "cloudtrail:ListPublicKeys",
      "cloudtrail:GetEventSelectors",
      "kms:ListAliases",
      "elasticloadbalancing:Describe*",
      "iam:ListUsers",
      "cloudwatch:ListMetrics",
      "cloudwatch:GetMetricStatistics",
      "cloudwatch:Describe*",
      "autoscaling:Describe*"
    ]
    resources = ["*"]
  }
}
