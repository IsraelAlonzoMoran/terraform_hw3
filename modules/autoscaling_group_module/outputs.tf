#Output to show the Autoscaling Group_id
output "terraform_asg_id" {
  value = aws_autoscaling_group.terraform-asg.id
}
