nat_gateway_name_regex = "^DevOps-NGw$"
# slb_cert_name_regex    = "^example.com"
ecs_instance_type  = "ecs.t6-c2m1.large"
eci_group_name     = "cockpit"
eci_image_uri      = "quay.io/cockpit/ws:latest"
eci_port           = 8080
eci_restart_policy = "Never"
subdomain          = "cockpit"
# root_domain            = "example.com"
# https://github.com/laradock/laradock/blob/b75d8ba0bd6527ff2a5ad879f111fa592e677c59/docker-compose.yml#L1498C39-L1498C39
