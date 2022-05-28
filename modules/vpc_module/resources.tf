# Create a VPC
resource "aws_vpc" "terraform-vpc" {
  cidr_block = var.vpc_cidr
  instance_tenancy ="default"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
        Name = "israel-terraform-vpc"
  }
}

#Create a Internet Gateway
resource "aws_internet_gateway" "terraform-internet-gw" {
  vpc_id = aws_vpc.terraform-vpc.id

  tags = {
        Name = "israel-terraform-internet-gw"
  }
}

#Create 3 public subnets:
#Create israelalonzo-terraform-public-subnet-1
resource "aws_subnet" "terraform-public-subnet-1" {
  vpc_id                  = aws_vpc.terraform-vpc.id
  cidr_block              = var.public_subnet1_cidr
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = true

  tags = {
        Name = "israel-terraform-public-subnet-1"
  }
}

#Create israelalonzo-terraform-public-subnet-2
resource "aws_subnet" "terraform-public-subnet-2" {
  vpc_id                  = aws_vpc.terraform-vpc.id
  cidr_block              = var.public_subnet2_cidr
  availability_zone       = "us-west-2b"
  map_public_ip_on_launch = true

  tags = {
        Name = "israel-terraform-public-subnet-2"
  }
}

#Create israelalonzo-terraform-public-subnet-3
resource "aws_subnet" "terraform-public-subnet-3" {  
  vpc_id                  = aws_vpc.terraform-vpc.id
  cidr_block              = var.public_subnet3_cidr
  availability_zone       = "us-west-2c"
  map_public_ip_on_launch = true

  tags = {
        Name = "israel-terraform-public-subnet-3"
  }
}
#Create 3 private subnets:
#Create israelalonzo-terraform-private-subnet-1
resource "aws_subnet" "terraform-private-subnet-1" {
  vpc_id                  = aws_vpc.terraform-vpc.id
  cidr_block              = var.private_subnet1_cidr
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = false

  tags = {
        Name = "israel-terraform-private-subnet-1"
  }
}

#Create israelalonzo-terraform-private-subnet-2
resource "aws_subnet" "terraform-private-subnet-2" { 
  vpc_id                  = aws_vpc.terraform-vpc.id
  cidr_block              = var.private_subnet2_cidr
  availability_zone       = "us-west-2b"
  map_public_ip_on_launch = false

  tags = {
        Name = "israel-terraform-private-subnet-2"
  }
}

#Create israelalonzo-terraform-private-subnet-3
resource "aws_subnet" "terraform-private-subnet-3" {
  vpc_id                  = aws_vpc.terraform-vpc.id
  availability_zone       = "us-west-2c"
  cidr_block              = var.private_subnet3_cidr
  map_public_ip_on_launch = false

  tags = {
        Name = "israel-terraform-private-subnet-3"
  }
}

#Create 2 RouteTables (1 Public, 1 Private)
#Create israelalonzo-terraform-public-route-table-1
resource "aws_route_table" "terraform-public-route-table-1" {
  vpc_id = aws_vpc.terraform-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.terraform-internet-gw.id

  }

  tags = {
        Name = "israel-terraform-public-route-table-1"
  }
}

#Create israelalonzo-terraform-public-route-table-1 with israelalonzo-terraform-public-subnet-1
resource "aws_route_table_association" "terraform-public-route-table-1-with-public-subnet-1" {
  subnet_id      = aws_subnet.terraform-public-subnet-1.id
  route_table_id = aws_route_table.terraform-public-route-table-1.id

}

#Create israelalonzo-terraform-public-route-table-1 with israelalonzo-terraform-public-subnet-2
resource "aws_route_table_association" "terraform-public-route-table-1-with-public-subnet-2" {
  subnet_id      = aws_subnet.terraform-public-subnet-2.id
  route_table_id = aws_route_table.terraform-public-route-table-1.id

}

#Create israelalonzo-terraform-public-route-table-1 with israelalonzo-terraform-public-subnet-3
resource "aws_route_table_association" "terraform-public-route-table-1-with-public-subnet-3" {
  subnet_id      = aws_subnet.terraform-public-subnet-3.id
  route_table_id = aws_route_table.terraform-public-route-table-1.id

}

#Create an Elastic IP that is required to create a NAT Gateway
#Allocate Elastic IP Address
resource "aws_eip" "terraform-eip-for-nat-gw" {
  vpc = true
  tags = {
        Name = "israel-terraform-eip-for-nat-gw"
  }
}

#Create a NAT Gateway
resource "aws_nat_gateway" "terraform-nat-gw" {
  allocation_id = aws_eip.terraform-eip-for-nat-gw.id
  subnet_id     = aws_subnet.terraform-public-subnet-1.id
  depends_on    = [aws_internet_gateway.terraform-internet-gw]
  tags = {
         Name = "israel-terraform-nat-gw"
    }
  }


#Create israelalonzo-terraform-private-route-table-1
resource "aws_route_table" "terraform-private-route-table-1" {
  vpc_id = aws_vpc.terraform-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.terraform-nat-gw.id
  }

  tags = {
    Name = "israel-terraform-private-route-table-1"
  }
}

#Create israelalonzo-terraform-private-route-table-1 with israelalonzo-terraform-private-subnet-1
resource "aws_route_table_association" "terraform-private-route-table-1-with-private-subnet-1" {
  subnet_id      = aws_subnet.terraform-private-subnet-1.id
  route_table_id = aws_route_table.terraform-private-route-table-1.id

}

#Create israelalonzo-terraform-private-route-table-1 with israelalonzo-terraform-private-subnet-2
resource "aws_route_table_association" "terraform-private-route-table-1-with-private-subnet-2" {
  subnet_id      = aws_subnet.terraform-private-subnet-2.id
  route_table_id = aws_route_table.terraform-private-route-table-1.id

}

#Create israelalonzo-terraform-private-route-table-1 with israelalonzo-terraform-private-subnet-3
resource "aws_route_table_association" "terraform-private-route-table-1-with-private-subnet-3" {
  subnet_id      = aws_subnet.terraform-private-subnet-3.id
  route_table_id = aws_route_table.terraform-private-route-table-1.id

}