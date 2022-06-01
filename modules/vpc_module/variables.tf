#Variables that we are using for the vpc_module

#This variable is here to allow to use the vpc_cidr in the resources.tf file, this variable is required to create the subnets, IG, NAT Gateway, etc.
variable "vpc_cidr" {
  description = "This is the CIDR the VPC is going to use, with a range definition of /16"
  default     = "172.30.0.0/16"
}

#This variable is added here as list(string) cause we are passing more that 1 availability zone.
variable "region-availability-zones" {
  type        = list(string)
  description = "List of AZs where the public and private subnets are going to be created"
  default     = ["us-west-2a", "us-west-2b", "us-west-2c", "us-west-2d"]
}