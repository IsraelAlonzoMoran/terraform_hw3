/* Here we have the Launch-configuration setting, we are also using 2 variables
1 for the instance_type and 1 for the security groups
for our EC2 instances we are going to use "Amazon Linux 2 AMI (HVM) (64-bit x86)"
Instance_type t2.micro
*/
resource "aws_launch_configuration" "terraform-launch-configuration" {
  name_prefix = "israel-terraform-launch-configuration"
  image_id        = data.aws_ami.amazon-linux-2.id
  instance_type   = var.instance_type
  security_groups = [var.terraform-allow-tls]

  lifecycle {
    create_before_destroy = true
  }
}

#Below the data code that is required by the resource "aws_launch_configuration" (image_id)
data "aws_ami" "amazon-linux-2" {
  owners = ["amazon"]
  most_recent = true

  filter {
   name   = "owner-alias"
   values = ["amazon"]
 }


 filter {
   name   = "name"
   values = ["amzn2-ami-hvm*"]
 }

  filter {
    name = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

}