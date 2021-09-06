variable "ami" {
  description = "An Amazon Machine Image provides the information required to launch an instance"
  type        = string
}

variable "instance_type" {
  description = "AWS instance type"
  type        = string
  default     = "t2.micro"
}

variable "instances_count" {
  description = "Number of instances to create"
  type        = number
  default     = 1
}

variable "key_name" {
  description = "Name for key pair"
  type        = string
}

variable "aws_vpc_id" {
  default = ""
}

variable "aws_pub_subnet" {
  default = ""
}

variable "aws_priv_subnet" {
  default = ""
}

variable "mysql_user" {
  default = "petclinic"
}

variable "mysql_db_name" {
  default = "petclinic"
}

variable "aws_access_key" {
}

variable "aws_secret_key" {
}

variable "region" {}