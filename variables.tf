#Variables
variable "passingstring" {
  type = string
}

variable "vpc_cidr" {
  type = string
  default = "172.30.0.0/16"
}

variable "public_subnet1_cidr" {
  type = string
  default = "172.30.0.0/24"
}

variable "public_subnet2_cidr" {
  type = string
  default = "172.30.1.0/24"
}

variable "public_subnet3_cidr" {
  type = string
  default = "172.30.2.0/24"
}

variable "private_subnet1_cidr" {
  type = string
  default = "172.30.3.0/24"
}

variable "private_subnet2_cidr" {
  type = string
  default = "172.30.4.0/24"
}

variable "private_subnet3_cidr" {
  type = string
  default = "172.30.5.0/24"
}