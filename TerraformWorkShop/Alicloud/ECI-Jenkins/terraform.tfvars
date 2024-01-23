resource_group_name_regex  = "^DevOps-Root"
vpc_name_regex             = "^DevOps-VPC_HK$"
vswitch_name_regex         = "^DevOps-VSw_HKB1_Sub$"
security_group_name_regex  = "^DevOps-SG_HKB1_Sub$"
nas_file_system_desc_regex = "^DevOps-NAS_HKB1$"
nat_gateway_name_regex     = "^DevOps-NGw_HKB1$"
load_balancer_name_regex   = "^DevOps-SLB_HKB1_Int$"
slb_cert_name_regex        = "9.com$"
domain_name_regex          = "9.com$"
agent_ecs_name_regex       = "^DevOps-ECS_HKB_Dev$"

ecs_instance_type      = "ecs.t6-c1m2.large"
eci_group_name         = "jenkins"
eci_image_uri          = "docker.io/jenkins/jenkins:lts-jdk17"
eci_port               = 8080
eci_restart_policy     = "Never"
jenkins_agent_listener = 50000
jenkins_casc_default   = "jcasc-default-config.yaml"
# jenkins_casc_admin_user = 
# jenkins_casc_admin_password = 

# jenkins_casc_cloud_docker = "jcasc-cloud-docker.yaml"
# jenkins_casc_addition = [{
#   file = "value"
# }]
subdomain = "jenkins"
# https://github.com/laradock/laradock/blob/b75d8ba0bd6527ff2a5ad879f111fa592e677c59/docker-compose.yml#L1498C39-L1498C39
