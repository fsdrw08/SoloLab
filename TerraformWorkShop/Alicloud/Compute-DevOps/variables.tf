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
  default = "^DevOps-Root-Disk-gitlab_data"
}

variable "ecs_image_name_regex" {
  type    = string
  default = "^centos_stream_9_uefi_x64"
}

variable "ecs_instance_type" {
  type        = string
  description = "https://www.alibabacloud.com/help/zh/elastic-compute-service/latest/instance-family"
  default     = "ecs.t6-c1m4.large" # ecs.t6-c1m2.large
}

variable "ecs_instance_name" {
  type    = string
  default = "DevOps-Root-ecs_gitlab"
}

variable "ecs_system_disk_name" {
  type    = string
  default = "DevOps-Root-ecs_gitlab_boot"
}

variable "ecs_server_name" {
  type    = string
  default = "git"
}

variable "ecs_status" {
  type    = string
  default = "Running" # Running / Stopped
}

variable "eip_address_name" {
  type    = string
  default = "DevOps"
}

variable "eip_index" {
  type    = number
  default = 0
}
