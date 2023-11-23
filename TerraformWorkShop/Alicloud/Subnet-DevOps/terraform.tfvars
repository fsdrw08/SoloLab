resource_group_name_regex = "^DevOps-Root"
vpc_name_regex            = "^DevOps-VPC"
nat_gateway_name_regex    = "^DevOps-NGw"

subnet_vswitches = [
  {
    zone_id             = "cn-hongkong-b"
    name                = "DevOps-Sub_HKB1_VSw"
    cidr_block          = "172.16.1.0/24"
    route_table_name    = "DevOps-Sub_HKB1_VSw_VTb"
    security_group_name = "DevOps-Sub_HKB1_SG"
  },
  {
    zone_id             = "cn-hongkong-c"
    name                = "DevOps-Sub_HKC1_VSw"
    cidr_block          = "172.16.2.0/24"
    route_table_name    = "DevOps-Sub_HKC1_VSw_VTb"
    security_group_name = "DevOps-Sub_HKC1_SG"
  }
]
