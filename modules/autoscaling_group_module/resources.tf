# Using Terraform locals to Tag all the EC2 instances
# with the DateTime when they got created
locals {
  asg-module-datetime = timestamp()
  israel-tf = "israel-terraform"
}

/*Here we have the Autoscaling_Group, the variable called "var.terraform-launch-configuration"
allow to use the lunch-configuration that we have in the other module called  "launch_configuration_module"
but, to be able to use it we need to add "terraform-launch-configuration" as variable in this module, variable as type string,
here we are also using other variable called "terraform-private-subnet", this variable is for the list of private subnets from the
VPC we have in the module called "vpc_module", cause we are going to laucnh our 2 EC2 instances using private subnets only.
*/
resource "aws_autoscaling_group" "terraform-asg" {
  name                      = "israel-terraform-asg-hw3"
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








