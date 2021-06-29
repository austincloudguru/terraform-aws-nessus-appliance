# AWS Nessus Appliance Module
[![CI](https://github.com/austincloudguru/terraform-aws-nessus-appliance/workflows/CI/badge.svg?event=push)](https://github.com/austincloudguru/terraform-aws-nessus-appliance/actions?query=workflow%3ACI) 
Terraform module which creates a nessus server in AWS

## Usage

```hcl
module "nessus" {
  source                 = "AustinCloudGuru/nessus-appliance/aws"
  # You should pin the module to a specific version
  # version              = "x.x.x"
  name                   = "nessus"
  license_type           = "byol"
  vpc_id                 = "vpc-0156c7c6959ba5858"
  subnet_ids             = ["subnet-05b1a3ffd786709d5", "subnet-0a35212c972a2af05", "subnet-0d0e78f696428aa28"]
  instance_type          = "m5.xlarge"
  nessus_key             = "dloiijfhqoiewrubfoqieuurbfcpoiqweunrcopiqeuhnrfpoiu13ehrwft"
  security_group_ingress = {
                             default = {
                               description = "NFS Inbound"
                               from_port   = 8834
                               protocol    = "tcp"
                               to_port     = 8834
                               self        = true
                               cidr_blocks = []
                             },
                             ssh = {
                               description = "ssh"
                               from_port   = 22
                               protocol    = "tcp"
                               to_port     = 22
                               self        = true
                               cidr_blocks = []
                             }
                           }
  nessus_key             = "dloiijfhqoiewrubfoqieuurbfcpoiqweunrcopiqeuhnrfpoiu13ehrwft"
  tags          = {
                    Terraform = "true"
                    Environment = "development"
                  } 
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.15.1, < 1.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~>3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~>3.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_instance_profile.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.ec2_readonly](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_instance.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.this_egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.this_ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_ami.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_iam_policy_document.assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | The type of instance to start | `string` | `"m5.xlarge"` | no |
| <a name="input_key_name"></a> [key\_name](#input\_key\_name) | The name of the key pair to use | `string` | `"aws-main"` | no |
| <a name="input_license_type"></a> [license\_type](#input\_license\_type) | The type of Nessus License to use: byob or preauth | `string` | `"byol"` | no |
| <a name="input_name"></a> [name](#input\_name) | Application Name | `string` | `"nessus"` | no |
| <a name="input_nessus_key"></a> [nessus\_key](#input\_nessus\_key) | Linking key used to register scanner with Tenable.io. | `string` | `""` | no |
| <a name="input_nessus_proxy"></a> [nessus\_proxy](#input\_nessus\_proxy) | FQDN/IP address of proxy, if required. | `string` | `""` | no |
| <a name="input_nessus_proxy_port"></a> [nessus\_proxy\_port](#input\_nessus\_proxy\_port) | Port used to connect to proxy, if required. | `string` | `""` | no |
| <a name="input_nessus_scanner_name"></a> [nessus\_scanner\_name](#input\_nessus\_scanner\_name) | Name of the scanner shown in the Nessus UI | `string` | `""` | no |
| <a name="input_product_code"></a> [product\_code](#input\_product\_code) | n/a | `map(any)` | <pre>{<br>  "byol": "8fn69npzmbzcs4blc4583jd0y",<br>  "preauth": "4m4uvwtrl5t872c56wb131ttw"<br>}</pre> | no |
| <a name="input_security_group_egress"></a> [security\_group\_egress](#input\_security\_group\_egress) | Can be specified multiple times for each egress rule. | <pre>map(object({<br>    description = string<br>    from_port   = number<br>    protocol    = string<br>    to_port     = number<br>    self        = bool<br>    cidr_blocks = list(string)<br>  }))</pre> | <pre>{<br>  "default": {<br>    "cidr_blocks": [<br>      "0.0.0.0/0"<br>    ],<br>    "description": "Allow All Outbound",<br>    "from_port": 0,<br>    "protocol": "-1",<br>    "self": false,<br>    "to_port": 0<br>  }<br>}</pre> | no |
| <a name="input_security_group_ingress"></a> [security\_group\_ingress](#input\_security\_group\_ingress) | Can be specified multiple times for each ingress rule. | <pre>map(object({<br>    description = string<br>    from_port   = number<br>    protocol    = string<br>    to_port     = number<br>    self        = bool<br>    cidr_blocks = list(string)<br>  }))</pre> | <pre>{<br>  "default": {<br>    "cidr_blocks": null,<br>    "description": "NFS Inbound",<br>    "from_port": 8834,<br>    "protocol": "tcp",<br>    "self": true,<br>    "to_port": 8834<br>  }<br>}</pre> | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | VPC Subnet ID to launch in | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The name of the VPC that EFS will be deployed to | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_image_id"></a> [image\_id](#output\_image\_id) | n/a |
| <a name="output_security_group_arn"></a> [security\_group\_arn](#output\_security\_group\_arn) | Security Group ARN |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | Security Group ID |
| <a name="output_security_group_name"></a> [security\_group\_name](#output\_security\_group\_name) | Security Group name |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
