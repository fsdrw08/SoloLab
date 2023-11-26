resource_group_name_regex = "^DevOps-Root"
vpc_name_regex            = "^DevOps-VPC"
ipv4_gateway_name_regex   = "^DevOps-IPV4Gw"
eip_address_name_regex    = "^DevOps-EIP_HK1"

nat_gateway_vswitch_zone_id          = "cn-hongkong-b"
nat_gateway_vswitch_name             = "DevOps-VSw_HKB_NGw1"
nat_gateway_vswitch_cidr             = "172.16.0.0/28"
nat_gateway_vswitch_route_table_name = "DevOps-VSw_VTb_HKB_NGw1"

nat_gateway_name          = "DevOps-NGw_HKB_1"
nat_gateway_description   = "This resource is managed by terraform"
nat_gateway_network_type  = "internet"
nat_gateway_eip_bind_mode = "NAT"
