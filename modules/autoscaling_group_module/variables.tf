/*Here we have the variables for the autoscaling group
 The varible terraform-private-subnet, is here to get the list of private subnets ids from the outputs.tf of the module called "vpc_module"
*/
variable "terraform-private-subnet" {
  type = set(string)
}

/*This is the variable we required to be able to use the launch-configuration for the autoscaling group
to be able to launch automatically the EC2 instances
*/
variable "terraform-launch-configuration" {
  type = string

}

