resource_group_name_regex = "^DevOps-Root"
vpc_name_regex            = "^DevOps-VPC_HK$"
vswitch_name_regex        = "^DevOps-VSw_HKB1_Sub$"
security_group_name_regex = "^DevOps-SG_HKB1_Sub$"
nat_gateway_name_regex    = "^DevOps-NGw_HKB1$"
load_balancer_name_regex  = "^DevOps-SLB_HKB1_Int$"
slb_cert_name_regex       = "9.com$"
domain_name_regex         = "9.com$"

ecs_instance_type  = "ecs.t6-c2m1.large"
eci_group_name     = "cockpit"
eci_image_uri      = "quay.io/cockpit/ws:latest"
eci_port           = 8080
eci_restart_policy = "Never"
subdomain          = "cockpit"
# https://github.com/laradock/laradock/blob/b75d8ba0bd6527ff2a5ad879f111fa592e677c59/docker-compose.yml#L1498C39-L1498C39
