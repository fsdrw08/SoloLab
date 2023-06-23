variable "resource_group_name" {
  type    = string
  default = "devops"
}

variable "vpc_name" {
  type    = string
  default = "DevOps"
}

variable "vswitch_name" {
  type    = string
  default = "DevOps"
}

variable "nat_gateway_name" {
  type    = string
  default = "DevOps"
}

variable "security_group_name" {
  type    = string
  default = "DevOps"
}

variable "ecs_instance_type" {
  type    = string
  default = "ecs.t6-c1m2.large"
}
variable "ecs_image_name" {
  type    = string
  default = "centos_stream_9_x64"
}

variable "ecs_server_name" {
  type    = string
  default = "gitlab"
}


variable "data_disk_name" {
  type    = string
  default = "DevOps_Disk-gitlab_data"
}

variable "eip_address_name" {
  type    = string
  default = "DevOps"
}

variable "eip_index" {
  type    = number
  default = 0
}
