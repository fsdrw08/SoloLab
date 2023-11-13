variable "resource_group_name_regex" {
  type    = string
  default = "^DevOps-Root"
}

variable "vpc_name_regex" {
  type    = string
  default = "^DevOps-VPC"
}

variable "vswitch_name_regex" {
  type    = string
  default = "^DevOps-Sub_1_VSw"
}

variable "security_group_name_regex" {
  type    = string
  default = "^DevOps-Sub_1_SG"
}

variable "eci_group_name" {
  description = "The name of the container group."
  type        = string
}

variable "ecs_instance_type" {
  description = "The type of the ECS instance to run the ECI."
  type        = string
  default     = "ecs.t6-c1m4.large "
}

variable "eci_restart_policy" {
  description = "The restart policy of the container group. Valid values: Always, Never, OnFailure."
  type        = string
  default     = "OnFailure"
}

variable "eci_image_uri" {
  description = "The image of the container, see https://hub.docker.com/r/gitlab/gitlab-ee"
  type        = string
  default     = "docker.io/gitlab/gitlab-ee:latest"
}

variable "GITLAB_OMNIBUS_CONFIG" {
  type = string
}
