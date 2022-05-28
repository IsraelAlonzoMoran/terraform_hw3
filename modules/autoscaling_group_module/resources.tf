/*Here we have the Autoscaling_Group, the variable called "var.terraform-launch-configuration"
allow to use the lunch-configuration that we have in the other module called  "launch_configuration_module"
but, to be able to use it we need to add "terraform-launch-configuration" as variable in this module, variable as type string,
here we are also using 3 variables; 1 for each private subnets from the VPC we have in the module called "vpc_module"
*/
resource "aws_autoscaling_group" "terraform-asg" {
  name = "israel-terraform-asg-hw2"
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







 
