resource_group_name_regex     = "^DevOps-Root"
vpc_name                      = "DevOps-VPC"
vpc_cidr                      = "172.16.0.0/12"
ipv4_gateway_name             = "DevOps-IPV4Gw"
ipv4_gateway_route_table_name = "DevOps-IPV4Gw_VTb"
private_zone_region_ids = [
  "cn-hongkong"
]
private_zone_user_id = "5408086620836608"
eip = {
  "DevOps-EIP_HK1" = {
    address_name         = "DevOps-EIP_HK1"
    payment_type         = "PayAsYouGo"
    internet_charge_type = "PayByTraffic"
    isp                  = "BGP"
    bandwidth            = 50
    description          = "This resource is managed by terraform"
  }
}
