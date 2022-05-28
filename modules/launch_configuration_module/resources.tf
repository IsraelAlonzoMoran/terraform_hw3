/* Here we have the Launch-configuration setting, we are also using 2 variables
1 for the instance_type and 1 for the security groups
for our EC2 instances we are going to use "Amazon Linux 2 AMI (HVM) - Kernel 5.10, SSD Volume Type - ami-0ca285d4c2cda3300 (64-bit x86)"
Instance_type t2.micro
*/
resource "aws_launch_configuration" "terraform-launch-configuration" {
  name_prefix            = "israel-terraform-asg-template-t2micro"
  image_id               = "ami-0ca285d4c2cda3300"
  instance_type          = var.instance_type
  security_groups        = [var.terraform-allow-tls]

  lifecycle {
    create_before_destroy = true
  }
}