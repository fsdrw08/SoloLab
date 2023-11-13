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
  default = "^DevOps-D_gitlab_data"
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
  default = "DevOps-ECS_gitlab"
}

variable "ecs_system_disk_name" {
  type    = string
  default = "DevOps-D_git_boot"
}

variable "ecs_server_name" {
  type    = string
  default = "git"
}

variable "ecs_podmgr_passwd_hash" {
  type        = string
  description = "Run this command to gen the hash: PASSWD='xxxx'; mkpasswd --method=SHA-512 --rounds=4096 $PASSWD"
  default     = "$6$rounds=4096$uELhWMpZ8N89hWdZ$jJcX1.Mjlsk8TdposASIUtAaOxamhkKdSq7V0mt9cJ8FX7coMCiEYtJt0lsX1rpKPoqYlc8gF7OUheZYwis3m0"
}

variable "ecs_status" {
  type    = string
  default = "Running" # Running / Stopped
}

variable "nat_gateway_name_regex" {
  type    = string
  default = "^DevOps-NGw"
}

variable "eip_address_name_regex" {
  type    = string
  default = "^DevOps-1"
}

variable "eip_index" {
  type    = number
  default = 0
}

variable "ssh_forward_entry_name" {
  type    = string
  default = "DevOps-fwd_git_ssh"
}

variable "http_forward_entry_name" {
  type    = string
  default = "DevOps-fwd_git_http"
}

variable "https_forward_entry_name" {
  type    = string
  default = "DevOps-fwd_git_https"
}
