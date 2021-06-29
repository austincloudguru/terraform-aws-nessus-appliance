variable "region" {
  description = "AWS Region"
  type        = string
  default     = "us-west-2"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default = {
    Environment = "terratest"
    Terraform   = "true"
  }
}
