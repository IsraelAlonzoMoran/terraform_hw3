# Terraform outputs, this is information that we want to export. Can be used as variable in other modules as well.

#This output is to export the terraform_vpc_id, that is going to be required as variable from the security group module.
output "terraform_vpc_id" {
  value = aws_vpc.terraform-vpc.id
}

#The below output is added here to export the private subnets ids from this vpc_module, this output is going to be required
#as variable from the autoscaling_group_module, cause the autoscaling groups is going to launch the EC2 instances
#using only private subnets, this is why will need the private subnets ids
output "terraform-private-subnet" {
  value = aws_subnet.terraform-private-subnet.*.id
}



