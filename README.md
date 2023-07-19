# AWS Nessus Appliance Module
[![Terratest](https://github.com/austincloudguru/terraform-aws-nessus-appliance/workflows/Terratest/badge.svg?event=push)](https://github.com/austincloudguru/terraform-aws-nessus-appliance/actions?query=workflow%3ATerratest) 
![Latest Version](https://img.shields.io/github/v/tag/austincloudguru/terraform-aws-nessus-appliance?sort=semver&label=Latest%20Version) 
[![License](https://img.shields.io/github/license/austincloudguru/terraform-aws-nessus-appliance)](https://github.com/austincloudguru/terraform-aws-nessus-appliance/blob/master/LICENSE)

Terraform module which creates a nessus server in AWS from Tenable's AMI for use with Tenable.io or Tenable.sc.  You will need to go to the AWS Marketplace and subscribe to the (Pre-Authorized or BYOL) image prior to building with Terraform. 

You will need to set the variable `license_type` to one of the following:
- preauth: If you are deploying a preauth server with Tenable.io
- byol: If you are using a BYOL license with Tenable.io
- byol-sc: If you are using a BYOL license with Tenable.sc

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
  tags          = {
                    Terraform = "true"
                    Environment = "development"
                  } 
}
```

### Deploying for Tenable.sc
This module can be used for deploying to Tenable.sc via the `byol-sc` license type.  Credentials are set via the `nessus_credentials` variable.  By default, the variable creates two new shell variables in the user_data script called `NESSUS_USER` and `NESSUS_PASS`. This is not secure since the variables will be visible in the Edit user_data section of the console.  For a more secure solution, you should pull the credentials from a secure location (S3, AWS Secrets Manager, Hashicorp Vault, etc) and set the variables.  For example, with Hashicorp Vault, you could define the `nessus_credentials` variable like this:
```
nessus_credentials = <<EOF
## Get Vault Token
VAULT_ADDR="https://vault.example.com"
VAULT_TOKEN=$(curl -X POST "$VAULT_ADDR/v1/auth/aws/login" -d '{"role":"ec2-default-role","pkcs7":"'$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/pkcs7 | tr -d '\n')'"}'|jq -r .auth.client_token)

## Setup Nessus Credentials
NESSUS_USER=$(curl -s --header "X-Vault-Token: $VAULT_TOKEN" $VAULT_ADDR/v1/globals/data/nessus_credentials|jq -r .data.data.username)
NESSUS_PASS=$(curl -s --header "X-Vault-Token: $VAULT_TOKEN" $VAULT_ADDR/v1/globals/data/nessus_credentials|jq -r .data.data.password)
EOF
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.15.1, < 1.2 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~>3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~>3.0 |
| <a name="provider_null"></a> [null](#provider\_null) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_autoscaling_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) | resource |
| [aws_iam_instance_profile.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.tenable-connector](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.tenable-connector](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_launch_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_configuration) | resource |
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.this_egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.this_ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [null_resource.tags_as_list_of_maps](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [aws_ami.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_iam_policy_document.assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.tenable-connector](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.tenable-connector-assume-role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_iam_statements"></a> [additional\_iam\_statements](#input\_additional\_iam\_statements) | Additional IAM statements for the ECS instances | <pre>list(object({<br>    effect    = string<br>    actions   = list(string)<br>    resources = list(string)<br>  }))</pre> | `[]` | no |
| <a name="input_associate_public_ip_address"></a> [associate\_public\_ip\_address](#input\_associate\_public\_ip\_address) | Whether to associate a public IP in the launch configuration | `bool` | `false` | no |
| <a name="input_cloud_connector"></a> [cloud\_connector](#input\_cloud\_connector) | Set to True if you want to install the IAM roles for cloud connector | `bool` | `false` | no |
| <a name="input_external_id"></a> [external\_id](#input\_external\_id) | Container ID in Cloud Connecter Advanced Settings | `string` | `""` | no |
| <a name="input_health_check_grace_period"></a> [health\_check\_grace\_period](#input\_health\_check\_grace\_period) | Time (in seconds) after instance comes into service before checking health | `number` | `300` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | The type of instance to start | `string` | `"m5.xlarge"` | no |
| <a name="input_key_name"></a> [key\_name](#input\_key\_name) | The name of the key pair to use | `string` | `"aws-main"` | no |
| <a name="input_license_type"></a> [license\_type](#input\_license\_type) | The type of Nessus License to use: byob or preauth | `string` | `"byol"` | no |
| <a name="input_name"></a> [name](#input\_name) | Application Name | `string` | `"nessus"` | no |
| <a name="input_nessus_credentials"></a> [nessus\_credentials](#input\_nessus\_credentials) | Environmental variables to use for Nessus scanner | `string` | `"NESSUS_USER='nessususer'\nNESSUS_PASS='p@ssw0rd'\n"` | no |
| <a name="input_nessus_key"></a> [nessus\_key](#input\_nessus\_key) | Linking key used to register scanner with Tenable.io. | `string` | `""` | no |
| <a name="input_nessus_proxy"></a> [nessus\_proxy](#input\_nessus\_proxy) | FQDN/IP address of proxy, if required. | `string` | `""` | no |
| <a name="input_nessus_proxy_port"></a> [nessus\_proxy\_port](#input\_nessus\_proxy\_port) | Port used to connect to proxy, if required. | `string` | `""` | no |
| <a name="input_nessus_scanner_name"></a> [nessus\_scanner\_name](#input\_nessus\_scanner\_name) | Name of the scanner shown in the Nessus UI | `string` | `""` | no |
| <a name="input_product_code"></a> [product\_code](#input\_product\_code) | n/a | `map(any)` | <pre>{<br>  "byol": "8fn69npzmbzcs4blc4583jd0y",<br>  "byol-sc": "8fn69npzmbzcs4blc4583jd0y",<br>  "preauth": "4m4uvwtrl5t872c56wb131ttw"<br>}</pre> | no |
| <a name="input_protect_from_scale_in"></a> [protect\_from\_scale\_in](#input\_protect\_from\_scale\_in) | Allows setting instance protection | `bool` | `false` | no |
| <a name="input_security_group_egress"></a> [security\_group\_egress](#input\_security\_group\_egress) | Can be specified multiple times for each egress rule. | <pre>map(object({<br>    description = string<br>    from_port   = number<br>    protocol    = string<br>    to_port     = number<br>    self        = bool<br>    cidr_blocks = list(string)<br>  }))</pre> | <pre>{<br>  "default": {<br>    "cidr_blocks": [<br>      "0.0.0.0/0"<br>    ],<br>    "description": "Allow All Outbound",<br>    "from_port": 0,<br>    "protocol": "-1",<br>    "self": false,<br>    "to_port": 0<br>  }<br>}</pre> | no |
| <a name="input_security_group_ingress"></a> [security\_group\_ingress](#input\_security\_group\_ingress) | Can be specified multiple times for each ingress rule. | <pre>map(object({<br>    description = string<br>    from_port   = number<br>    protocol    = string<br>    to_port     = number<br>    self        = bool<br>    cidr_blocks = list(string)<br>  }))</pre> | <pre>{<br>  "default": {<br>    "cidr_blocks": null,<br>    "description": "NFS Inbound",<br>    "from_port": 8834,<br>    "protocol": "tcp",<br>    "self": true,<br>    "to_port": 8834<br>  }<br>}</pre> | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | The Subnet IDs | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |
| <a name="input_termination_policies"></a> [termination\_policies](#input\_termination\_policies) | A list of policies to decide how the instances in the auto scale group should be terminated | `list(string)` | <pre>[<br>  "OldestInstance",<br>  "Default"<br>]</pre> | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The name of the VPC that EFS will be deployed to | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_asg_name"></a> [asg\_name](#output\_asg\_name) | Name of the Autoscaling Group |
| <a name="output_image_id"></a> [image\_id](#output\_image\_id) | n/a |
| <a name="output_role_arn"></a> [role\_arn](#output\_role\_arn) | Role ARN |
| <a name="output_security_group_arn"></a> [security\_group\_arn](#output\_security\_group\_arn) | Security Group ARN |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | Security Group ID |
| <a name="output_security_group_name"></a> [security\_group\_name](#output\_security\_group\_name) | Security Group name |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
