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

variable "zone_available_instance_type" {
  type    = string
  default = "ecs.t6-c1m4.large"
}

variable "subnet_vswitches" {
  type = list(object({
    # https://www.alibabacloud.com/help/en/eci/product-overview/regions-and-zones
    zone_id             = string
    name                = string
    cidr_block          = string
    route_table_name    = string
    security_group_name = string
  }))
}
