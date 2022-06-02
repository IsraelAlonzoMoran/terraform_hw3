## Terraform Homework 3
## Description: 
#### In this homework 3 we are going to create the below infrastructure as a code using Terraform and AWS as a provider.
## Terraform Template
*  VPC Module
* - VPC
* - Internet Gateway
* - 3 Public Subnets
* - 3 Private Subnets
* - 2 RouteTables (1 Public, 1 Private)
* - NAT Gateway
* - Elastic IP
- Launch Configuration Module
- Autoscaling Group Module
- Security Group Module
- Tag all the resources with the DateTime when they got created (Use Terraform locals)
- Generate dynamic CIDR for the subnets using Terraform functions
- Iterate to create a number of public and private subnets equal to the number of availability zones the Region has
- Use a `data` to get the AMI for the AutoScaling Group


#### The Terraform template has the following structure.
#### Project name "TERRAFORM_HW3" inside it a folder called modules.
* modules
* *  vpc_module
* * - outputs.tf
* * - resources.tf
* * - variables.tf
* *  launch_configuration_module
* * - outputs.tf
* * - resources.tf
* * - variables.tf
* *  autoscaling_group_module
* * - outputs.tf
* * - resources.tf
* * - variables.tf
* *  sg_module
* * - outputs.tf
* * - resources.tf
* * - variables.tf
* terraform_hw3.tf
* variables.tf

In the project folder called "terraform_hw3", inside it, we have a main file called "terraform_hw3.tf", in this file we are going to add the path of each module, this way from this main file we are going to be able to call each module and be able to pass values to each variables.tf file that we have defined in each module, this will help to communicate/connect our modules. The variables name that we have in each module needs to be added to the main file as well, this way the variables can receive the respective values as needed. When adding the variables in the main file make sure to include the module reference if using a module outputs.tf file to get the id, name, etc from other modules.

Here we have the main file "terraform_hw3.ft.

Just to show some code from the main file. Here we are using AWS as the provider, we are also adding the region that we are using for this project (Oregon us-west-2), from here we are also passing values for the vpc_module, values for the variable vpc_cidr, for the variable called "region-availability-zones". From this main file we are passing some values to the variables we have in each module of the project.

```bash
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider
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

```
#
## VPC Module

In the vpc_module you are going to find the Terraform code to create an AWS VPC, internet gateway, public subnets, private subnets, 2 RouteTables (1 public and 1 private), an Elastic IP, NAT Gateway and the respective associations between the resources.

In the VPC Module we are also using some Terraform Functions like cidrsubnet, index, element, length, we are using these functions to generate dynamic CIDR for the subnets as well as iterate to create a number of public and private subnets equal to the number of availability zones the Region has, to complete these 2 instrucstions we are using Terraform Functions.

For example in the vpc_module(resources.tf), in this file, you are going to find the Terraform code that was used to create the AWS VPC. In this example "terraform-vpc" is the name that is been used as the VPC id, if you want to reference the VPC by the id, "terraform-pvc" needs to be used, this can be any other name/words you would like to add there, make sure to add a cidr_block, in this case, we are using a variable called "vpc_cidr", the variable is in the same vpc_module, when using variables make sure to include var.(follow by the variable name as shown below). You can include tags for the resources that are going to be created, also as described below you enable dns_support and dns_hostname for the VPC.

### We have an instruction to "Tag all the resources with the DateTime when they got created(Use Terraform locals)".
#
To complete this instruction `Terraform Locals` was used as shown below.

Using Terraform locals values; a local value assigns a name to an expression, for this project as expression we are using `formatdate(spec, timestamp)` cause with "formatdate(spec, timestamp)"; "spec" helps to give date and time format and with "timestamp()" we get the Date and Time when each AWS resource got created. Below you are going to see the code "formatdate("MMMM DD, YYYY hh:mm:ss ZZZ", timestamp())".

For example in the "vpc_module" resources.tf file, the Local values block was declared as NAME = "vpc-module-datetime" and as EXPRESSION = "formatdate("MMMM DD, YYYY hh:mm:ss ZZZ", timestamp())". Once the local value is declared we can reference it in expression as local.NAME. Important note to take in consideration when declaring Local values. Local values are created by a `locals` block as plural, but when we reference them as attributes on an object named `local` as singular. Local value can only be accessed in expressions within the module where it was declared, is also really helpful to avoid repeating the same values multiple times in a configuration, for example to avoid repeating "israel-terraform" we can use NAME = "israel-tf", EXPRESSION = "israel-terraform", then if later on we need to update the value "israel-terraform" we only need to update the EXPRESSION value and all the resources that are referencing these local values are going to get the new values automatically, this is why is really useful. Terraform Local values was used and added in the "resources.tf" file of each module of this project to get the DateTime when each AWS resource got created and also to avoid repeating the string "israel-terraform".

The code below was added in to the vpc_module(resources.tf). Code below describe how to declare the Local values and how to use it for the VPC tags. Same way was used for the rest of AWS resources that we created in each module of this project.
```bash
#Declaring a Local Values
locals {
  vpc-module-datetime = formatdate("MMMM DD, YYYY hh:mm:ss ZZZ", timestamp())
  israel-tf           = "israel-terraform"
}

# Terraform resource to create an AWS VPC
# The cidr_block value is defined in the project main file called "terraform-hw3.tf", 
# the main file is passing the value to the variable defined in vpc_module(variables.tf).
resource "aws_vpc" "terraform-vpc" {
    
  cidr_block = var.vpc_cidr
  instance_tenancy ="default"
  enable_dns_support = true
  enable_dns_hostnames = true
  #This is how we reference Local Values, example: ${local.vpc-module-datetime} 
  tags = {
    Name = "${local.israel-tf}-vpc-${local.vpc-module-datetime}"
  }
}

#Create an Internet Gateway
resource "aws_internet_gateway" "terraform-internet-gw" {
  vpc_id = aws_vpc.terraform-vpc.id
  #This is how we reference Local Values, example: ${local.israel-tf} 
  tags = {
    Name = "${local.israel-tf}-internet-gw-${local.vpc-module-datetime}"
  }
}
```
The code below needs to be in the vpc_module(variables.tf). Terraform variables, this variable is used for the vpc cidr_block.
```bash

variable "vpc_cidr" {
  default = "172.30.0.0/16"
}
```
### Here we have 2 instructions to create the subnets for this project, we completed these 2 instructions with the code below.
- Generate dynamic CIDR for the subnets using Terraform functions.
- Iterate to create a number of public and private subnets equal to the number of availability zones the Region has.

#### Generate dynamic CIDR for the subnets using Terraform functions.
#

 For this part we are using Terraform Function(IP Network Functions; cidrsubnet), this function helps to calculate a subnet address within given IP network address prefix.
 ```bash
 cidrsubnet(prefix, newbits, netnum)
 ```
 First, "prefix" must be given in CIDR notation, in this project is the vpc_cidr, and here "prefix" is "aws_vpc.terraform-vpc.cidr_block".
 
 Then we have "newbits", newbits is for the number of additional bits with which to extend the prefix. For example, in this project we are using a prefix ending in /16 and a newbits value of 8, the resulting subnet address will have length /24.
 
 The last part is "netnum", netnum is a whole number that can be represented as a binary integer with no more than newbits binary digits, which will be used to populate the additional bits added to the prefix. We are using netnum (including count.index) to let the netnum to start at zero, but then add value of 10 for the public subnets and add 20 for the private subnets.
 
#### Iterate to create a number of public and private subnets equal to the number of availability zones the Region has.
#
Based on this other instruction that the project should be able to do. This instruction was completed using Terraform Function(Collection Function; length, index), with length we get the length of the list that we have in the variable called "region-availability-zones",cause in the variable "region-availability-zones", we have all the Availability Zones that are in the Oregon region (us-west-2) and index finds the element index for a given value in a list, here count.index is used to loop through the variable list.

* Create public subnets(4 public subnets are going to be created based that the Oregon region us-west-2 only has 4 Availability zones): One public subnet for each given AZ.


Below the public subnets cidr that are going to be created. Starting at 10, 11, 12 and 13 cause we indicated in the netnum to start at 10. After the count.index started from zero_based.
```bash
	
#israel-terraform-public-subnet-0  172.30.10.0/24  us-west-2a  us-west-2
#israel-terraform-public-subnet-1  172.30.11.0/24  us-west-2b  us-west-2	
#israel-terraform-public-subnet-2  172.30.12.0/24  us-west-2c  us-west-2
#israel-terraform-public-subnet-3  172.30.13.0/24  us-west-2d  us-west-2	

resource "aws_subnet" "terraform-public-subnet" {
  count      = length(var.region-availability-zones)
  vpc_id     = aws_vpc.terraform-vpc.id
  cidr_block = cidrsubnet(aws_vpc.terraform-vpc.cidr_block, 8, count.index + 10)
  #Here we are also using Terraform Function(Collection Function; index) 
  #index finds the element index for a given value in a list.
  #index is been used here to find each availability zone
  #that is in the list (variable (region-availability-zones))
  availability_zone       = var.region-availability-zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${local.israel-tf}-public-subnet-${count.index}-${local.vpc-module-datetime}"
  }
}
```
* Create private subnets(4 private subnets are going to be created based that the Oregon region us-west-2 only has 4 Availability zones): One private subnet for each given AZ.


Below the private subnets cidr that are going to be created. Starting at 20, 21, 22 and 23 cause we indicated in the netnum to start at 20. After the count.index started from zero_based.
```bash

#israel-terraform-private-subnet-0  172.30.20.0/24  us-west-2a  us-west-2
#israel-terraform-private-subnet-1  172.30.21.0/24  us-west-2b  us-west-2
#israel-terraform-private-subnet-2  172.30.22.0/24  us-west-2c  us-west-2
#israel-terraform-private-subnet-3  172.30.23.0/24  us-west-2d  us-west-2

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

```
The Terraform Function "element" was used in this project as well, element retrieves a single element from a list, here was used to associate the subnets to the Route Tables, to the NAT Gateway for example, as shown below.
```bash
# Association (All private Subnets to the private Route Table)
resource "aws_route_table_association" "terraform-private-route-table-to-private-subnet" {
  count          = length(var.region-availability-zones)
  subnet_id      = element(aws_subnet.terraform-private-subnet.*.id, count.index)
  route_table_id = aws_route_table.terraform-private-route-table.id

}
```
In each module there is a file called "outputs.tf", in this file we add information that we want to export. The outputs added in the file "outputs.tf" can be used as variable in other modules as well, this is helpful, cause for example in this project we required the VPC id and private subnets ids in other modules, and to be able to use these ids we need to add them in the vpc_module(outputs.tf) file.

Add the code below in the vpc_module(outputs.tf). 
```bash
output "terraform_vpc_id" {
  value = aws_vpc.terraform-vpc.id
}
#The below output is added here to export the private subnets ids from this vpc_module,
#this output is going to be required as variable from the autoscaling_group_module,
#cause the autoscaling group is going to launch the EC2 instances using only private subnets,
#this is why will need the private subnets ids

output "terraform-private-subnet" {
  value = aws_subnet.terraform-private-subnet.*.id
}
```
For example in this project we are using a Security Group for the AWS Infrastructure, to associate a Security Group to the VPC we need an output from the vpc_module to be used as variable in the sg_module.


Add the code below in the sg_module(variables.tf). By adding the code below as variable we now can reference to the pc_module(vpc_id), this is helpful cause now we can also use this variable inside the sg_module(resources.tf) as shown below.
```bash
variable "terraform_vpc_id" {
    type = string
}

```
And now we can use the variable that is in the sg_module.

This is the resources.tf file that is inside the sg_module.
```bash
resource "aws_security_group" "terraform-allow-tls" {
    name = var.name
    #As shown here we can use the variable we have in sg_module(variables.tf), var.terraform_vpc_id.
    vpc_id = var.terraform_vpc_id
 # Using variables for the ports, these variables need to be declared in the variables.tf file
 # of this same sg_module, and the values can be in the main project directory file called "terraform_hw3.tf"
 # when calling all modules.  The cidr_blocks = ["0.0.0.0/0"] can be customized for the ingress and egress
 # as needed in this project we are not adding restrictions but can be added.
ingress {
        description = "tls for VPC"
        from_port   = var.port
        to_port     = var.port
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
}

egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
}

tags = {
        Name = "${local.israel-tf}-sg-${local.sg-module-datetime}"
}

}
```
Terraform outputs, we are adding this output here to be exported cause we required the security group as variable in the module called launch_configuration_module"
```bash
output "terraform-allow-tls" {
  value = aws_security_group.terraform-allow-tls.id
}
```
#
## Launch Configuration Module

In the launch_configuration_module you are going to find the Terraform code that is required by the Autoscaling Group module to be able to launch EC2 instances.

Below we have 2 variables, 1 to indicate the instance type and the other to be able to use the security group from the module called "sg_module".

```bash
variable "instance_type" {
    type = string
    description = "EC2 instance type for the Terraform AWS launch configuration"
    default = "t2.micro"
}

variable "terraform-allow-tls" {
    type = string
}

```
#### Use a `data` to get the AMI for the AutoScaling Group
#
Here in `data` we are adding owners as "amazon" and some filters to get the ID of a registered AMI, using the filters shown below we are going to get the following AMI "Amazon Linux 2 AMI (HVM) - Kernel 4.14, SSD Volume Type - ami-00af37d1144686454 (64-bit x86), gp2", then the `data` will be used in the resources "aws_launch_configuration", image_id as "image_id = data.aws_ami.amazon-linux-2.id".


Below the data code that helps to complete the above instruction.

```bash
#This Terraform code needs to be inside the resources.tf file.
data "aws_ami" "amazon-linux-2" {
  owners      = ["amazon"]
  most_recent = true

  filter {
    name = "name"
    values = ["amzn2-ami-hvm-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  
}
```
Below the Launch-configuration resource, we are also using 2 variables, 1 for the instance_type and 1 for the security group. The EC2 instances are going to be launched as instance_type t2.micro.
```bash
#This Terraform code needs to be inside the resources.tf file.
#Here we need to add the data code in the image_id, as shown below.
#image_id = data.aws_ami.amazon-linux-2.id
#We are using Local values to avoid repeating the string "israel-terraform" and for the DateTime as well.
resource "aws_launch_configuration" "terraform-launch-configuration" {
  name_prefix     = "${local.israel-tf}-launch-configuration-${local.lc-module-datetime}"
  image_id        = data.aws_ami.amazon-linux-2.id
  instance_type   = var.instance_type
  security_groups = [var.terraform-allow-tls]

  lifecycle {
    create_before_destroy = true
  }
}

```
Terraform outputs, here we are adding "terraform-launch-configuration.name", using .name cause this is what the autoscaling group needs to recognize the launch-configuration that we have in this module(resources.tf) file.
```bash

output "terraform-launch-configuration" {
  value = aws_launch_configuration.terraform-launch-configuration.name
}

```
#
## Autoscaling Group Module


Here we have the Autoscaling Group, the variable called "var.terraform-launch-configuration" allow to use the launch-configuration that we have in the other module called  "launch_configuration_module" but, to be able to use it we need to add "terraform-launch-configuration" as variable in this module, variable as type string, here we are also using a variable called "terraform-private-subnet" this is to allow the Autoscaling Group to launch EC2 instances in the private subnets only from the VPC we have in the module called "vpc_module".

Here in the variables.tf file we have the variables for the Autoscaling Group.

```bash
#This is the variable we need to be able to use the launch-configuration for the autoscaling group
#to be able to launch automatically the EC2 instances in the private subnets.

variable "terraform-private-subnet" {
  type = set(string)
}

variable "terraform-launch-configuration" {
  type = string

}
```
The Autoscaling Group as shown below is going to let us launch 2 EC2 instances cause we have our min, max, and desired capacity as 2, this means that if for some reason an EC2 instance is stopped or terminated the Autoscaling Group is going to launch a new EC2 instance automatically. Main reason why we are using it here to help us to avoid having system downtime, 4 availability zones here cause we have the private subnets in different availability zones, this way the EC2 instance can be launch in any of the Availability zones, this is also to prevent system downtime caused by outages.
```bash
resource "aws_autoscaling_group" "terraform-asg" {
  name                      = "${local.israel-tf}-asg-hw3-${local.asg-datetime}"
  vpc_zone_identifier       = var.terraform-private-subnet
  launch_configuration      = var.terraform-launch-configuration
  desired_capacity          = 2
  max_size                  = 2
  min_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "EC2"
  force_delete              = true

  tag {
    key                 = "Name"
    value               = "${local.israel-tf}-asg-EC2-instance-${local.asg-module-datetime}"
    propagate_at_launch = true
  }

}
```
And this is the last part of the Autoscaling Group.

Output to export/show the Autoscaling Group id.
```bash
output "terraform_asg_id" {
  value = aws_autoscaling_group.terraform-asg.id
}
```
#

### Finally to test the Terraform Template use the below commands.
#
While inside the project directory that has the main "terraform_hw3.tf" file:

Type terraform init, terraform init command is used to initialize a working directory containing Terraform configuration files.
```bash
terraform init
```
Once terraform init is completed, then type terraform apply, terraform apply command executes the actions proposed, in this case action to create the AWS infrastructure based on the Terraform Template.

```bash
terraform apply
```

And last if you would like to destroy the AWS infrastructure you just created, run terraform destroy.

```bash
terraform destroy
```

## Below more information about this project
Steps that can help to prepare the host machine to be able to run the Terraform Template.

Step 1: Download the Terraform package for the OS(this Terraform code was tested in Ubuntu-20.04.4-amd64 64-bit) in the following link: https://www.terraform.io/downloads

Step 2: Unzip the downloaded Terraform package(The Terraform package will look like "terraform_1.1.9_linux_amd64.zip", unzip it).

Step 3: Once the package is unzipped "terraform_1.1.9_linux_amd64", open it and copy the binary called "terraform", then paste the binary called "terraform" in the host machine path /usr/local/bin.

Step 4: Open the host machine Linux terminal and type $terraform --version (it will show the Terraform version).

```bash
terraform --version
#You'll see a Terraform version like this(the version number may be different for you).
Terraform v1.1.9
on linux_amd64
```

Step 5: Open the host machine Linux terminal and type $aws configure(enter the AWS_ACCESS_KEY_ID, then the AWS_SECRET_ACCESS_KEY, hit enter if the region is correct otherwise type(us-west-2), then hit enter again for the output format(these steps will help to test that access to the AWS account is allow, cause to create an AWS VPC and the rest of the VPC resources, access to the AWS account with the right permissions to create resources is required, otherwise create your AWS account with these permissions).

```bash
aws configure

```

Step 6: Clone the terraform_hw3 to your local machine.

```bash
git clone https://github.com/IsraelAlonzoMoran/terraform_hw3.git

```
Step 7: Once the "terraform_hw3" project is downloaded to the host machine, open the Linux Terminal and with $cd go to the directory that has the downloaded folder, example "$cd /home/alonzo/Downloads/terraform_hw3".

Step 8: Once in the directory that has the "terraform_hw3.tf" file:

Type terraform init, terraform init command is used to initialize a working directory containing Terraform configuration files.
```bash
terraform init
```
Once terraform init is completed, then type terraform apply, terraform apply command executes the actions proposed, in this case action to create the AWS infrastructure based on the Terraform Template.

```bash
terraform apply
```

And last if you would like to destroy the AWS infrastructure you just created, run terraform destroy.

```bash
terraform destroy
```

Step 9: Go to the AWS Console(https://aws.amazon.com/) select Sing in, enter your credentials, type VPC in the search option and review that the AWS VPC and rest of resources have been created.

That's all. Thank you.