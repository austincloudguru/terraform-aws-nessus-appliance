variable "name" {
  description = "Application Name"
  type        = string
  default     = "nessus"
}

variable "license_type" {
  description = "The type of Nessus License to use: byob or preauth"
  type        = string
  default     = "byol"
  validation {
    condition     = var.license_type == "byol" || var.license_type == "byol-sc" || var.license_type == "preauth"
    error_message = "Sorry, type must be either 'byob' or 'preauth'."
  }
}

variable "product_code" {
  type = map(any)
  default = {
    "byol"    = "8fn69npzmbzcs4blc4583jd0y"
    "byol-sc" = "8fn69npzmbzcs4blc4583jd0y"
    "preauth" = "4m4uvwtrl5t872c56wb131ttw"
  }
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "security_group_ingress" {
  description = "Can be specified multiple times for each ingress rule. "
  type = map(object({
    description = string
    from_port   = number
    protocol    = string
    to_port     = number
    self        = bool
    cidr_blocks = list(string)
  }))
  default = {
    default = {
      description = "NFS Inbound"
      from_port   = 8834
      protocol    = "tcp"
      to_port     = 8834
      self        = true
      cidr_blocks = null
    }
  }
}

variable "security_group_egress" {
  description = "Can be specified multiple times for each egress rule. "
  type = map(object({
    description = string
    from_port   = number
    protocol    = string
    to_port     = number
    self        = bool
    cidr_blocks = list(string)
  }))
  default = {
    default = {
      description = "Allow All Outbound"
      from_port   = 0
      protocol    = "-1"
      to_port     = 0
      self        = false
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}

variable "additional_iam_statements" {
  description = "Additional IAM statements for the ECS instances"
  type = list(object({
    effect    = string
    actions   = list(string)
    resources = list(string)
  }))
  default = []
}

variable "vpc_id" {
  description = "The name of the VPC that EFS will be deployed to"
  type        = string
}

variable "instance_type" {
  description = "The type of instance to start"
  type        = string
  default     = "m5.xlarge"
}

variable "key_name" {
  description = "The name of the key pair to use"
  type        = string
  default     = "aws-main"
}

variable "subnet_id" {
  description = "VPC Subnet ID to launch in"
  type        = string
  default     = ""
}

variable "nessus_key" {
  description = "Linking key used to register scanner with Tenable.io."
  type        = string
  default     = ""
}

variable "nessus_scanner_name" {
  description = "Name of the scanner shown in the Nessus UI"
  type        = string
  default     = ""
}

variable "nessus_proxy" {
  description = "FQDN/IP address of proxy, if required."
  type        = string
  default     = ""
}

variable "nessus_proxy_port" {
  description = "Port used to connect to proxy, if required."
  type        = string
  default     = ""
}

variable "external_id" {
  description = "Container ID in Cloud Connecter Advanced Settings"
  type        = string
  default     = ""
}

variable "cloud_connector" {
  description = "Set to True if you want to install the IAM roles for cloud connector"
  type        = bool
  default     = false
}

variable "nessus_credentials" {
  description = "Environmental variables to use for Nessus scanner"
  type        = string
  default     = <<EOF
NESSUS_USER='nessususer'
NESSUS_PASS='p@ssw0rd'
EOF
}
