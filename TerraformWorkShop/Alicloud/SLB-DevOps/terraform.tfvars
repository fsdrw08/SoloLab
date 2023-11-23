resource_group_name_regex = "^DevOps-Root"
vpc_name_regex            = "^DevOps-VPC"
# nat_gateway_name_regex    = "^DevOps-NGw"

slb_web_internal = [
  {
    vswitch_name_regex     = "^DevOps-Sub_HKB1_VSw"
    name                   = "DevOps-SLB"
    instance_charge_type   = "PayByCLCU"
    load_balancer_spec     = "slb.s1.small"
    listener_backend_port  = 8080
    nat_gateway_name_regex = "^DevOps-NGw"
    eip_name_regex         = "^DevOps-EIP-1"
  }
]
