variable "resource_group_name_regex" {
  type = string
}

variable "vpc_name_regex" {
  type = string
}

variable "vswitch_name_regex" {
  type = string
}

variable "security_group_name_regex" {
  type = string
}

variable "load_balancer_name_regex" {
  type = string
}

variable "domain_name_regex" {
  type = string
}

variable "slb_cert_name_regex" {
  description = "A regex string to filter results by server certificate name."
  type        = string
}

variable "nat_gateway_name_regex" {
  type = string
}

variable "nas_file_system_desc_regex" {
  type = string
}

variable "agent_ecs_name_regex" {
  type = string
}

variable "eci_group_name" {
  description = "The name of the container group."
  type        = string
}

variable "ecs_instance_type" {
  description = "The type of the ECS instance to run the ECI. https://www.alibabacloud.com/help/zh/elastic-compute-service/latest/instance-family"
  type        = string
  # default     = "ecs.t6-c1m2.large" # https://www.alibabacloud.com/help/zh/ecs/user-guide/overview-of-instance-families#e
}

variable "eci_restart_policy" {
  description = "The restart policy of the container group. Valid values: Always, Never, OnFailure."
  type        = string
  default     = "OnFailure"
}

variable "eci_image_uri" {
  description = "The image of the container, see https://hub.docker.com/r/jenkins/jenkins/tags"
  type        = string
  default     = "docker.io/jenkins/jenkins:lts-jdk17"
}

variable "eci_auto_img_cache" {
  description = "Specifies whether to automatically match the image cache. "
  type        = bool
  default     = true
}
variable "eci_port" {
  type    = number
  default = 8080
}

variable "jenkins_agent_listener" {
  type    = number
  default = 50000
}

variable "jenkins_admin_password" {
  type = string
}

variable "jenkins_casc_default" {
  description = "default jenkins config as code file"
  type        = string
  default     = "jcasc-default-config.yaml"
}

variable "jenkins_casc_admin_user" {
  description = "default jenkins admin user name"
  type        = string
}

variable "jenkins_casc_admin_password" {
  description = "default jenkins admin user password"
  type        = string
}

variable "jenkins_casc_cloud_docker" {
  description = "jenkins config as code file for docker cloud"
  type        = string
  default     = "jcasc-cloud-docker.yaml"
}

variable "jenkins_casc_addition" {
  type = list(object({
    file = string
  }))
  default = [{
    file = ""
  }]
}

variable "subdomain" {
  type    = string
  default = "jenkins"
}
