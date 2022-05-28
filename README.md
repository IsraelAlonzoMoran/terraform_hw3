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
- Generate dynamic CIDR for the subnets using Terraform functions
- Iterate to create a number of public and private subnets equal to the number of availability zones the Region has
- Use a `data` to get the AMI for the AutoScaling Group
- Tag all the resources with the DateTime when they got created (Use Terraform locals)

#### The Terraform template has the following structure.
#### Project name "TERRAFORM_HW3" inside of it a folder called modules.
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

Here we hve the main file "terraform_hw3.ft.

Just to show some code from the main file. Here we have the provider in this case AWS, we are also adding the region that we are using for this project (Oregon us-west-2), from here we are also passing the values for the vpc_cidr, the cidr for the 3 public subnest and 3 private subnets. From here we are passing some values to the variables we have in each module of the project.

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
  source = "./modules/vpc_module"
  vpc_cidr = "172.30.0.0/16"
  public_subnet1_cidr = "172.30.0.0/24"
  public_subnet2_cidr = "172.30.1.0/24"
  public_subnet3_cidr = "172.30.2.0/24"
  private_subnet1_cidr  = "172.30.3.0/24"
  private_subnet2_cidr  = "172.30.4.0/24"
  private_subnet3_cidr  = "172.30.5.0/24"
}

# Calling the Launch_Configuration_Module
module "terraform_launch_configuration_hw3" {
  source = "./modules/launch_configuration_module"
  instance_type = "t2.micro"
  terraform-allow-tls = module.terraform_sg_hw3.terraform-allow-tls
}

# Calling the Autoscaling_Group_Module
module "terraform_autoscaling_group_hw3" {
  source = "./modules/autoscaling_group_module"
  terraform-private-subnet-1_id = module.terraform_vpc_hw3.terraform-private-subnet-1_id
  terraform-private-subnet-2_id = module.terraform_vpc_hw3.terraform-private-subnet-2_id
  terraform-private-subnet-3_id = module.terraform_vpc_hw3.terraform-private-subnet-3_id
  terraform-launch-configuration = module.terraform_launch_configuration_hw3.terraform-launch-configuration
}

# Calling the Security Group Module
module "terraform_sg_hw3" {
  source = "./modules/sg_module"
  terraform_vpc_id  = module.terraform_vpc_hw3.terraform_vpc_id
  name = "terraform_sg_hw"
  port = 8080
}

```
#
## VPC Module

In the vpc_module you are going to find the Terraform code to create an AWS VPC, internet_gateway, 3 public subnets, 3 private subnets, 2 RouteTables (1 public and 1 private), an Elastic IP, NAT Gateway and the respective associations between the resources.

For example in the vpc_modue(resources.tf), in this file, you are going to find the Terraform code that was used to create the AWS VPC. In this example "terraform-vpc" is the name that is been used as the VPC id, if you want to reference the VPC by the id, "terraform-pvc" needs to be used, this can be any other name/words you would like to add there, make sure to add a cidr_block, in this case, we are using a variable called "vpc_cidr", the variable is in the same vpc_module, when using variables make sure to include var.(follow by the variable name as showing below). You can also include tags for the VPC, here the tag is "israel-terraform-vpc", can be any other name, also as described below this is how you enable dns_support and dns_hostname for the VPC.
```bash
# This code needs to be in the vpc_module(resources.tf)
# Terraform resources, to Create a AWS VPC
# The cidr_block value is defined in the project main file called "terraform-hw3.tf", this main file is pasing the value to the variable defined in vpc_module(variables.tf).
resource "aws_vpc" "terraform-vpc" {
    
  cidr_block = var.vpc_cidr
  instance_tenancy ="default"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
        Name = "israel-terraform-vpc"
  }
}
```

This code needs to be in the vpc_module(variables.tf). Terraform variables, this variable is used for the vpc cidr_bock.
```bash

variable "vpc_cidr" {
  default = "172.30.0.0/16"
}
```

Add this code in the vpc_module(outputs.tf). Terraform outputs, here we add information that we want to export. Can be used as variable in other modules as well.
```bash
output "terraform_vpc_id" {
  value = aws_vpc.terraform-vpc.id
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

 # Using variables for the ports, these variables need to be declared in the variables.tf file of this same sg_module, and the values can be in the main project directory file called "terraform_hw3.tf" when calling all modules.  The cidr_blocks = ["0.0.0.0/0"] can be customized for the ingress and egress as needed in this project we are not adding restrictions but can be added.
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
        Name = "israel-terraform-sg"
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

In the launch_configuration_module you are going to find the Terraform code that is required by the Autoscaling group module to be able to launch EC2 instances.

Below we have 2 variables, 1 to indicate the instance type and the other to be able to use the security group from the module called "sg_module".

```bash
variable "instance_type" {
    type = string
    description = "EC2 instance type for the terraform aws launch configuration"
    default = "t2.micro"
}

variable "terraform-allow-tls" {
    type = string
}

```
 Below the Launch-configuration setting, we are also using 2 variables, 1 for the instance_type and 1 for the security group, to launch the EC2 instances we are going to use "Amazon Linux 2 AMI (HVM) - Kernel 5.10, SSD Volume Type - ami-0ca285d4c2cda3300 (64-bit x86)", instance_type t2.micro.

```bash
#This terraform code needs to be inside the resources.tf file.
resource "aws_launch_configuration" "terraform-launch-configuration" {
  name_prefix            = "israel-terraform-asg-template-t2micro"
  image_id               = "ami-0ca285d4c2cda3300"
  instance_type          = var.instance_type
  security_groups        = [var.terraform-allow-tls]

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


Here we have the Autoscaling_Group, the variable called "var.terraform-launch-configuration" allow to use the launch-configuration that we have in the other module called  "launch_configuration_module" but, to be able to use it we need to add "terraform-launch-configuration" as variable in this module, variable as type string, here we are also using 3 variables; 1 for each private subnets from the VPC we have in the module called "vpc_module".

Here in the variables.tf file we have the variables for the autoscaling group.

```bash
#This is the variable we need to be able to use the launch-configuration for the autoscaling group to be able to launch automatically the EC2 instances in any of the 3 private subnets.
variable "terraform-launch-configuration" {
  type = string

}

variable "terraform-private-subnet-1_id" {
  type = string
  
}

variable "terraform-private-subnet-2_id" {
  type = string
  
}

variable "terraform-private-subnet-3_id" {
  type = string
  
}

```

The Autoscaling Group as shown below is going to let us launch 2 EC2 instances cause we have our min, max, and desired capacity as 2, this means that if for some reason an EC2 instance is stopped or terminated the Autoscaling Group is going to launch a new EC2 instance automatically. Main reason why we are using it here to help us to avoid having system downtime, we are also using 3 availability zones here cause we have the subnets in differnt availability zones, this way the EC2 instance t2.micro can be launch in any of these 3 Availability zones this is also to prevent system downtime caused by outages.
```bash
resource "aws_autoscaling_group" "terraform-asg" {
  name = "israel-terraform-asg-hw3"
  vpc_zone_identifier = [var.terraform-private-subnet-1_id, var.terraform-private-subnet-2_id, var.terraform-private-subnet-3_id]
  launch_configuration = var.terraform-launch-configuration
  desired_capacity   = 2
  max_size           = 2
  min_size           = 2
  health_check_grace_period = 300
  health_check_type = "EC2"
  force_delete = true
  

  tag {
    key                 = "Name"
    value               = "israel-terraform-asg-for-EC2-instance"
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
Once the terraform init is completed, then Type terraform apply, terraform apply command executes the actions proposed, in this case action to create the AWS infrastructure based on the Terraform Template.

```bash
terraform apply
```

And last if you would like to destroy the AWS infrastructure you just created, run terraform destroy.

```bash
terraform destroy
```

## Below more information about this project
Steps that can help to prepare the host machine to be able to run the Terraform Template.

Step 1: Download the Terraform package for the OS(this terraform code was tested in Ubuntu-20.04.4-amd64 64-bit) in the following link: https://www.terraform.io/downloads

Step 2: Unzip the downloaded terraform package(The terraform package will look like "terraform_1.1.9_linux_amd64.zip", unzip it).

Step 3: Once the package is unzipped "terraform_1.1.9_linux_amd64", open it and copy the binary called "terraform", then paste the binary called "terraform" in the host machine path /usr/local/bin.

Step 4: Open the host machine Linux terminal and type $terraform --version (it will show the terraform version).

```bash
terraform --version
```

Step 5: Open the host machine Linux terminal and type $aws configure(enter the AWS_ACCESS_KEY_ID, then the AWS_SECRET_ACCESS_KEY, hit enter if the region is correct otherwise type(us-west-2), then hit enter again for the output format(these steps will help to test that access to the AWS account is allow, cause to create an aws vpc and the rest of the vpc resources access to the aws account with the right permissions to create resources is required, otherwise create your AWS account with these permissions).

```bash
aws configure
```

Step 6: Clone the terraform_hw3 to your local machine.

```bash
git clone https://github.com/IsraelAlonzoMoran/terraform_hw3.git

```
Step 7: Once the "terraform_hw3" project is downloaded to the host machine, with $cd go to the directory that has the downloaded folder, example "$cd /home/alonzo/Downloads/terraform_hw3".

Step 8: Once in the directory that has the "terraform_hw3.tf" file:

Type terraform init, terraform init command is used to initialize a working directory containing Terraform configuration files
```bash
terraform init
```
Once the terraform init is completed, then Type terraform apply, terraform apply command executes the actions proposed, in this case action to create the AWS infrastructure based on the Terraform Template.

```bash
terraform apply
```

And last if you would like to destroy the AWS infrastructure you just created, run terraform destroy.

```bash
terraform destroy
```

Step 9: Go to the AWS Console(https://aws.amazon.com/) select Sing in, enter your credentinals, type vpc in the search option and review that the aws vpc and rest of resources have been created.

That's all. Thank you.