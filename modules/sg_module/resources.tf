#Here we have the security group, we are using here 2 variables for the ingress ports
resource "aws_security_group" "terraform-allow-tls" {

    name = var.name
    vpc_id = var.terraform_vpc_id
  
ingress {
        description = "tls for VPC"
        from_port   = var.port
        to_port     = var.port
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
}

egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
}

        tags = {
        Name = "israel-terraform-sg"
  }

}