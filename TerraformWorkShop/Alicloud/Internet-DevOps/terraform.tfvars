resource_group_name_regex = "^DevOps-Root"

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
