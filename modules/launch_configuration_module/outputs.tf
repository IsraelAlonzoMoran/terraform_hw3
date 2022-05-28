/*Terraform outputs, here we are adding "terraform-launch-configuration.name", using .name cause
this is what the autoscaling group needs to recognize the lunch-configuration that we have here.
*/
output "terraform-launch-configuration" {
  value = aws_launch_configuration.terraform-launch-configuration.name
}
