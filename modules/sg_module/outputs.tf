/* Terraform outputs, we are adding this output here to be exported
cause we required the security group as variable in the module called "launch_configuration_module"
*/
output "terraform-allow-tls" {
  value = aws_security_group.terraform-allow-tls.id
}
