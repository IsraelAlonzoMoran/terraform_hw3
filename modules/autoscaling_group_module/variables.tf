/*Here we have the variables for the autoscaling group
*/

variable "terraform-private-subnet-1_id" {
  type = string
  
}

variable "terraform-private-subnet-2_id" {
  type = string
  
}

variable "terraform-private-subnet-3_id" {
  type = string
  
}

/*This is the variable we required to be able to use the launch-configuration for the autoscaling group
to be able to launch automatically the EC2 instances
*/
variable "terraform-launch-configuration" {
  type = string

}