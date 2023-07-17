variable "resource_group_name_regex" {
  type    = string
  default = "^DevOps-Root"
}

variable "vpc_name_regex" {
  type    = string
  default = "^DevOps-VPC"
}

variable "ipv4_gateway_name_regex" {
  type    = string
  default = "^DevOps-IPV4Gw"
}

variable "nat_gateway_vswitch_name" {
  default = "DevOps-NGw_VSw"
}

variable "nat_gateway_vswitch_cidr" {
  type    = string
  default = "172.16.1.0/24"
}

variable "nat_gateway_vswitch_route_table_name" {
  type    = string
  default = "DevOps-NGw_VSw_VTb"
}


# nat gateway
variable "nat_gateway_name" {
  type    = string
  default = "DevOps-NGw"
}

# eip
variable "nat_gateway_eip_address_name" {
  type    = string
  default = "DevOps"
}

variable "nat_gateway_eip_bandwidth" {
  type    = number
  default = 50
}

variable "nat_gateway_eip_internet_charge_type" {
  type    = string
  default = "PayByTraffic"
}

# variable "domain_name" {
#   type = string
# }
