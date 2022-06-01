# Using Terraform locals to Tag all the "vpc_module" resources
# with the DateTime when they got created
locals {
    vpc-module-datetime = timestamp()
    israel-tf = "israel-terraform" 
}

# Create a VPC
resource "aws_vpc" "terraform-vpc" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${local.israel-tf}-vpc-${local.vpc-module-datetime}"
  }
}


#Create a Internet Gateway
resource "aws_internet_gateway" "terraform-internet-gw" {
  vpc_id = aws_vpc.terraform-vpc.id

  tags = {
    Name = "${local.israel-tf}-internet-gw-${local.vpc-module-datetime}"
  }
}

# Here we have 2 instructions for this project, we completed these 2 instructions with the code below.

#- Generate dynamic CIDR for the subnets using Terraform functions
/*
 For this part we are using Terraform Function(IP Network Functions; cidrsubnet), this function helps to calculate a subnet address
 within given IP network address prefix.
 #cidrsubnet(prefix, newbits, netnum)
 
 #"prefix" must be given in CIDR notation, in this project is the vpc_cidr, and for us the "prefix" here is "aws_vpc.terraform-vpc.cidr_block"
 
 "newbits" this is for the number of additional bits with which to extend the prefix. 
  For example, in this project we are using a prefix ending in /16 and a newbits value of 8, the resulting subnet address will have length /24.
 
 "netnum" is a whole number that can be represented as a binary integer with no more than newbits binary digits,
  which will be used to populate the additional bits added to the prefix.
  Here in this project we are using netnum (including count.index), this is to let the netnum to start at zero,
  in this project we are letting the netnum to start at zero but then add 10 for the public subnets and add 20 for the private subnets.
 */

#- Iterate to create a number of public and private subnets equal to the number of availability zones the Region has
/* Also based on this other instruction that the project should be able to do.
  We completed this instruction using Terraform Function(Collection Function; length), with length we get the length of the list
  that we have in the variable called "region-availability-zones",cause in the variable "region-availability-zones" 
  we have all the Availability Zones that are in the Oregon region (us-west-2).
*/

#Create public subnets(4 public subnets are going to be created cause the Oregon region us-west-2 only has 4 Availability zones):
#One public subnet for each given AZ.
#Below the public subnets cidr that are going to be created. Starting at 10, 11, 12 and 13 cause we indicated in the netnum to start at 10.
#after the count.index started from zero_based
/*	
israel-terraform-public-subnet-0	172.30.10.0/24 us-west-2a	us-west-2
israel-terraform-public-subnet-1  172.30.11.0/24 us-west-2b	us-west-2	
israel-terraform-public-subnet-2	172.30.12.0/24 us-west-2c	us-west-2
israel-terraform-public-subnet-3	172.30.13.0/24 us-west-2d	us-west-2	
*/

resource "aws_subnet" "terraform-public-subnet" {
  count      = length(var.region-availability-zones)
  vpc_id     = aws_vpc.terraform-vpc.id
  cidr_block = cidrsubnet(aws_vpc.terraform-vpc.cidr_block, 8, count.index + 10)
  #Here we are also using Terraform Function(Collection Function; index) index finds the element index for a given value in a list.
  #index is been used here to find each availability zone that is in the list (variable (region-availability-zones))
  availability_zone       = var.region-availability-zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${local.israel-tf}-public-subnet-${count.index}-${local.vpc-module-datetime}"
  }
}

#Create private subnets(4 private subnets are going to be created cause the region of Oregon us-west-2 only has 4 Availability zones):
#One private subnet for each given AZ.
#Below the private subnets cidr that are going to be created. Starting at 20, 21, 22 and 23 cause we indicated in the netnum to start at 20.
#after the count.index started from zero_based
/*
israel-terraform-private-subnet-0 172.30.20.0/24 us-west-2a	us-west-2
israel-terraform-private-subnet-1 172.30.21.0/24 us-west-2b	us-west-2
israel-terraform-private-subnet-2 172.30.22.0/24 us-west-2c	us-west-2
israel-terraform-private-subnet-3 172.30.23.0/24 us-west-2d	us-west-2
*/
resource "aws_subnet" "terraform-private-subnet" {
  count                   = length(var.region-availability-zones)
  vpc_id                  = aws_vpc.terraform-vpc.id
  cidr_block              = cidrsubnet(aws_vpc.terraform-vpc.cidr_block, 8, count.index + 20)
  availability_zone       = var.region-availability-zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${local.israel-tf}-private-subnet-${count.index}-${local.vpc-module-datetime}"
  }
}

#Create 2 RouteTables (1 Public, 1 Private)
#Create israelalonzo-terraform-public-route-table
resource "aws_route_table" "terraform-public-route-table" {
  vpc_id = aws_vpc.terraform-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.terraform-internet-gw.id

  }

  tags = {
    Name = "${local.israel-tf}-public-route-table-${local.vpc-module-datetime}"
  }
}

# Associations (All public Subnets to the public Route Table)
resource "aws_route_table_association" "terraform-public-route-table-to-public-subnet" {
   count = length(var.region-availability-zones)
  #using Function (collection function; element), element retrieves a single element from a list, here is been used for the subnets ids.
  subnet_id      = element(aws_subnet.terraform-public-subnet.*.id, count.index)
  route_table_id = aws_route_table.terraform-public-route-table.id

}

#Create israelalonzo-terraform-private-route-table
resource "aws_route_table" "terraform-private-route-table" {
  vpc_id = aws_vpc.terraform-vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.terraform-nat-gw.id
  }

  tags = {
    Name = "${local.israel-tf}-private-route-table-${local.vpc-module-datetime}"
  }
}

# Associations (All private Subnets to the private Route Table)
resource "aws_route_table_association" "terraform-private-route-table-to-private-subnet" {
  count          = length(var.region-availability-zones)
  subnet_id      = element(aws_subnet.terraform-private-subnet.*.id, count.index)
  route_table_id = aws_route_table.terraform-private-route-table.id

}

#Create an Elastic IP that is required to create a NAT Gateway
#Allocate Elastic IP Address
resource "aws_eip" "terraform-eip-for-nat-gw" {
  vpc = true
  tags = {
    Name = "${local.israel-tf}-eip-for-nat-gw-${local.vpc-module-datetime}"
  }
}

#Create a NAT Gateway
resource "aws_nat_gateway" "terraform-nat-gw" {
  allocation_id = aws_eip.terraform-eip-for-nat-gw.id
  subnet_id     = element(aws_subnet.terraform-public-subnet.*.id, 0)
  depends_on    = [aws_internet_gateway.terraform-internet-gw]
  tags = {
    Name = "${local.israel-tf}-nat-gw-${local.vpc-module-datetime}"
  }
}