variable "aws_region" {
  type = string
  default = "eu-central-1"
}

# TF_VAR_aws_access_key
variable "aws_access_key" {
  type = string
}

# TF_VAR_aws_secret_key
variable "aws_secret_key" {
  type = string
}

variable "service_name" {
  default = "nginx"
}

variable "aws_ami" {
  description = "An Amazon Machine Image provides the information required to launch an instance"
  type = string
  default = "ami-06ec8443c2a35b0ba"
}

variable "aws_key_name" {
  description = "Name for key pair"
  type = string
  default = "id_rsa"
}