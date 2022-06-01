# Using Terraform locals to Tag all the "launch_configuration_module" resources
# with the DateTime when they got created
locals {
  lc-module-datetime = timestamp()
  israel-tf = "israel-terraform"
}
/* Here we have the Launch-configuration setting, we are also using 2 variables
1 for the instance_type and 1 for the security groups
for our EC2 instances we are going to use "Amazon Linux 2 AMI (HVM) - Kernel 4.14, SSD Volume Type - ami-00af37d1144686454 (64-bit x86), pg2"
Instance_type t2.micro
*/
resource "aws_launch_configuration" "terraform-launch-configuration" {
  name_prefix     = "israel-terraform-launch-configuration"
  image_id        = data.aws_ami.amazon-linux-2.id
  instance_type   = var.instance_type
  security_groups = [var.terraform-allow-tls]

  lifecycle {
    create_before_destroy = true
  }
}

#Use a `data` to get the AMI for the AutoScaling Group
#Below the data code that is required to complete the above instruction,
#the data code is required by the resource "aws_launch_configuration" (image_id) as "image_id = data.aws_ami.amazon-linux-2.id"
data "aws_ami" "amazon-linux-2" {
  owners      = ["amazon"]
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

}
