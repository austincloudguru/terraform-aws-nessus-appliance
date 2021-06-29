variable "region" {
  description = "AWS Region"
  type        = string
  default     = "us-west-2"
}

variable "tld" {
  description = "Top Level Domain"
  type        = string
  default     = "austincloud.net"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default = {
    Environment = "terratest"
    Terraform   = "true"
  }
}
