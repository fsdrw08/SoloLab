variable "resource_group_name_regex" {
  type    = string
  default = "^DevOps-Root"
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

variable "slb_cert_name_regex" {
  description = "A regex string to filter results by server certificate name."
  type        = string
}

variable "nat_gateway_name_regex" {
  type = string
}

variable "domain_name_regex" {
  type = string
}

variable "eci_group_name" {
  description = "The name of the container group."
  type        = string
}

variable "ecs_instance_type" {
  description = "The type of the ECS instance to run the ECI. https://www.alibabacloud.com/help/zh/elastic-compute-service/latest/instance-family"
  type        = string
  # default     = "ecs.t6-c4m1.large" # https://www.alibabacloud.com/help/zh/ecs/user-guide/overview-of-instance-families#e
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

variable "subdomain" {
  type    = string
  default = "jenkins"
}

# variable "root_domain" {
#   description = "value"
#   type        = string
# }
