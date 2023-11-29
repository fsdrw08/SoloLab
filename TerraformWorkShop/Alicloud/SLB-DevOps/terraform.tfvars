resource_group_name_regex = "^DevOps-Root"
vpc_name_regex            = "^DevOps-VPC"

slb_web_internal = {
  "DevOps-SLB_HKB1_Intkey" = {
    vswitch_name_regex     = "^DevOps-VSw_HKB1_Sub"
    name                   = "DevOps-SLB_HKB1_Int"
    instance_charge_type   = "PayByCLCU"
    load_balancer_spec     = "slb.s1.small"
    listener_backend_port  = 8080
    nat_gateway_name_regex = "^DevOps-NGw_HKB1"
    eip_name_regex         = "^DevOps-EIP_HK1"
  }
}
