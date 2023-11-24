variable "resource_group_name_regex" {
  type = string
}

variable "vpc_name_regex" {
  type = string
}

variable "ipv4_gateway_name_regex" {
  type = string
}

variable "eip_address_name_regex" {
  type = string
}

# nat gateway vswitch
variable "nat_gateway_vswitch_zone_id" {
  type = string
}

variable "nat_gateway_vswitch_name" {
  type = string
}

variable "nat_gateway_vswitch_cidr" {
  type = string
}

variable "nat_gateway_vswitch_route_table_name" {
  type = string
}


# nat gateway
variable "nat_gateway_name" {
  type = string
}

variable "nat_gateway_description" {
  type = string
}

variable "nat_gateway_network_type" {
  type        = string
  description = <<EOT
Indicates the type of the created NAT gateway. 
Valid values internet and intranet. 
internet: Internet NAT Gateway. 
intranet: VPC NAT Gateway.
EOT
}

variable "nat_gateway_eip_bind_mode" {
  type        = string
  description = <<EOT
The EIP binding mode of the NAT gateway. Default value: MULTI_BINDED. Valid values:
  MULTI_BINDED: Multi EIP network card visible mode.
  NAT: EIP normal mode, compatible with IPv4 gateway.
EOT
}
