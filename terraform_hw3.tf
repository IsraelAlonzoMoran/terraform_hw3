terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

#  Configure the AWS Provider
provider "aws" {
  region = var.aws_region

}

# Calling the VPC_Module
module "terraform_vpc_hw3" {
  source                    = "./modules/vpc_module"
  vpc_cidr                  = "172.30.0.0/16"
  region-availability-zones = ["us-west-2a", "us-west-2b", "us-west-2c", "us-west-2d"]
}

# Calling the Launch_Configuration_Module
module "terraform_launch_configuration_hw3" {
  source              = "./modules/launch_configuration_module"
  instance_type       = "t2.micro"
  terraform-allow-tls = module.terraform_sg_hw3.terraform-allow-tls
}

# Calling the Autoscaling_Group_Module
module "terraform_autoscaling_group_hw3" {
  source                         = "./modules/autoscaling_group_module"
  terraform-launch-configuration = module.terraform_launch_configuration_hw3.terraform-launch-configuration
  terraform-private-subnet       = module.terraform_vpc_hw3.terraform-private-subnet
}

# Calling the Security Group Module
module "terraform_sg_hw3" {
  source           = "./modules/sg_module"
  terraform_vpc_id = module.terraform_vpc_hw3.terraform_vpc_id
  name             = "terraform_sg_hw"
  port             = 8080
}
