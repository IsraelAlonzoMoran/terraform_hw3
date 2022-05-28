#These variables are going to be used for the main "terraform_hw2.tf" also for the resources.tf in this module.
#here we are also using the output from the module called "vpc_module" cause we required to associate the
#security group with the vpc.
variable "terraform_vpc_id" {
    type = string
}

variable "name" {
     type = string
}

variable "port" {
    type = number
}

