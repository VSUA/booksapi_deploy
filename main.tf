terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
//  backend "s3" {
//    bucket = "terraformstatenginx"
//    key = "global/s3/terraform.tfstate"
//    region = "eu-central-1"
//    dynamodb_table = "terraformstate"
//  }
}

provider "aws" {
  region = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

module "network" {
  source = "./modules/network"
  service_name = var.service_name
  aws_region = var.aws_region
}

//module "nginx" {
//  source = "./modules/nginx"
//  aws_vpc_id = module.network.aws_vpc_id
//  aws_priv_subnet = module.network.aws_priv_subnet
//  aws_pub_subnet = module.network.aws_pub_subnet
//  service_name = var.service_name
//}

//module "dynamodb" {
//  source = "./modules/dynamodb"
//  region = var.aws_region
//  vpc_id = module.network.aws_vpc_id
//  pub_rt_id = module.network.aws_pub_rt_id
//}

//module "petclinic" {
//  source = "./modules/petclinic"
//  aws_vpc_id = module.network.aws_vpc_id
//  aws_priv_subnet = module.network.aws_priv_subnet
//  aws_pub_subnet = module.network.aws_pub_subnet
//  ami = var.aws_ami
//  key_name = var.aws_key_name
//  region = var.aws_region
//  aws_access_key = var.aws_access_key
//  aws_secret_key = var.aws_secret_key
//}

//resource "local_file" "hosts" {
//  content     = module.petclinic.instances_public_ip[0]
//  filename = "/etc/ansible/hosts"
//  file_permission = "400"
//}

module "booksapi" {
  source = "./modules/booksapi_cluster"
  cluster_name = "cluster"
  priv_subnets = module.network.aws_priv_subnet
  pub_subnets = module.network.aws_pub_subnet
  service_name = "random"
  vpc_id = module.network.aws_vpc_id
}