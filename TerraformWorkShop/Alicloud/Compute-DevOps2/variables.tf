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

variable "data_disk_name_regex" {
  type    = string
  default = "^DevOps-D_agent_data"
}

variable "ecs_image_name_regex" {
  type    = string
  default = "^fedora"
}

variable "ecs_instance_type" {
  type        = string
  description = "https://www.alibabacloud.com/help/zh/elastic-compute-service/latest/instance-family"
  default     = "ecs.t6-c1m4.large" # ecs.t6-c1m2.large
}

variable "ecs_instance_name" {
  type    = string
  default = "DevOps-ECS_agent"
}

variable "ecs_system_disk_name" {
  type    = string
  default = "DevOps-D_agent_boot"
}

variable "ecs_server_name" {
  type    = string
  default = "agent"
}

variable "ecs_admin_passwd_hash" {
  type        = string
  description = "Run this command to gen the hash: PASSWD='xxxx'; mkpasswd --method=SHA-512 --rounds=4096 $PASSWD"
  default     = "$6$rounds=4096$PXUQwSJNV/SGxOgA$O1/YBCMkI6RyOAFmb0hJw3iNRpdYFjnG/11NeuOeVhHCukdTE8wDlodFZu/tUFqpKZ6DDbp0lS1FaVVqfNaSQ1"
}

variable "ecs_status" {
  type    = string
  default = "Running" # Running / Stopped
}
