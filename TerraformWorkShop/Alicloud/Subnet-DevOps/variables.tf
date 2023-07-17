variable "resource_group_name_regex" {
  type    = string
  default = "^DevOps-Root"
}

variable "vpc_name_regex" {
  type    = string
  default = "^DevOps-VPC"
}

variable "nat_gateway_name_regex" {
  type    = string
  default = "^DevOps-NGw"
}

variable "subnet_vswitch_name" {
  default = "DevOps-Sub_1_VSw"
}

variable "subnet_vswitch_cidr" {
  type    = string
  default = "172.16.2.0/24"
}

variable "subnet_vswitch_route_table_name" {
  type    = string
  default = "DevOps-Sub_1_VSw_VTb"
}

variable "subnet_security_group_name" {
  type    = string
  default = "DevOps-Sub_1_SG"
}
