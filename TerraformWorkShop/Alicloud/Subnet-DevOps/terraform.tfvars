resource_group_name_regex = "^DevOps-Root"
vpc_name_regex            = "^DevOps-VPC"
nat_gateway_name_regex    = "^DevOps-NGw"

subnet_vswitches = {
  "DevOps-VSw_HKB1_Sub" = {
    zone_id             = "cn-hongkong-b"
    name                = "DevOps-VSw_HKB1_Sub"
    cidr_block          = "172.16.1.0/24"
    route_table_name    = "DevOps-VSw_HKB1_Sub_VTb"
    security_group_name = "DevOps-SG_HKB1_Sub"
  }
  "DevOps-VSw_HKC1_Sub" = {
    zone_id             = "cn-hongkong-c"
    name                = "DevOps-VSw_HKC1_Sub"
    cidr_block          = "172.16.2.0/24"
    route_table_name    = "DevOps-VSw_HKC1_Sub_VTb"
    security_group_name = "DevOps-SG_HKC1_Sub"
  }
}
