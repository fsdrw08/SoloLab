variable "resource_group_name_regex" {
  type    = string
  default = "^DevOps"
}

variable "vpc_name" {
  type    = string
  default = "DevOps-VPC"
}

variable "vpc_cidr" {
  type    = string
  default = "172.16.0.0/12"
}

variable "ipv4_gateway_enabled" {
  type    = bool
  default = true
}
variable "ipv4_gateway_name" {
  type    = string
  default = "DevOps-IPV4Gw"
}

variable "ipv4_gateway_route_table_name" {
  type        = string
  description = "ipv4 gateway route table name"
  default     = "DevOps-IPV4Gw_VTb"
}

variable "private_zone_user_id" {
  type    = string
  default = "5408086620836608"
}

variable "private_zone_region_ids" {
  type    = list(string)
  default = ["cn-hongkong"]
}
