nat_gateway_name_regex = "^DevOps-NGw$"
# slb_cert_name_regex    = "^example"
eci_group_name     = "whoami"
eci_image_uri      = "ghcr.io/traefik/whoami:v1.9.0"
eci_restart_policy = "Always"
subdomain = "whoami"
# root_domain = "example.com"
# https://github.com/laradock/laradock/blob/b75d8ba0bd6527ff2a5ad879f111fa592e677c59/docker-compose.yml#L1498C39-L1498C39
