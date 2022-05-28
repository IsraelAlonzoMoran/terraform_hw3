/*Here we have the 2 variables, 1 to indicate the instance type and the other to be able to use the
security group from the module called "sg_module"
*/
variable "instance_type" {
    type = string
    description = "EC2 instance type for the terraform aws launch configuration"
    default = "t2.micro"
}


variable "terraform-allow-tls" {
  
  type = string

}