/*Using Terraform locals to Tag the ASG and all EC2 instances with the DateTime when they got created
  Local values, (name = asg-module-datetime) to tag all the EC2 instances
  Local values, (name = asg-datetime) to tag the ASG, using "hh'h'mm'm'ss's'" this way cause
  the ASG doesn't accept the colon : character as part of its name.
*/
locals {
  asg-module-datetime = formatdate("MMMM DD, YYYY hh:mm:ss ZZZ", timestamp())
  asg-datetime        = formatdate("MMMM DD, YYYY hh'h'mm'm'ss's' ZZZ", timestamp())
  israel-tf           = "israel-terraform"
}

/*Here we have the Autoscaling_Group, the variable called "var.terraform-launch-configuration"
  allow to use the lunch-configuration that we have in the other module called  "launch_configuration_module"
  but, to be able to use it we need to add "terraform-launch-configuration" as variable in this module, variable as type string,
  here we are also using other variable called "terraform-private-subnet", this variable is for the list of private subnets from the
  VPC we have in the module called "vpc_module", cause we are going to laucnh our 2 EC2 instances using private subnets only.
*/
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








