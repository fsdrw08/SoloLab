nat_gateway_name_regex = "^DevOps-NGw$"
# slb_cert_name_regex    = "^example"
nas_file_system_desc_regex = "^DevOps-NAS$"
ecs_instance_type = "ecs.t6-c1m4.large"
eci_group_name     = "jenkins"
eci_image_uri      = "docker.io/jenkins/jenkins:lts-jdk17"
eci_port           = 8080
eci_restart_policy = "Never"
# jenkins_admin_password = "123"
jenkins_casc = [ 
  {
    name = "jenkins-cm-jcasc-default"
    path = "jcasc-default-config.yaml"
    content = templatefile("jcasc-default-config.yaml",{ root_domain = var.subdomain})
  }
]
subdomain = "jenkins"
# root_domain = "example.com"
# https://github.com/laradock/laradock/blob/b75d8ba0bd6527ff2a5ad879f111fa592e677c59/docker-compose.yml#L1498C39-L1498C39
