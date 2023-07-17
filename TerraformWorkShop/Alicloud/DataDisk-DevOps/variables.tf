variable "resource_group_name_regex" {
  type    = string
  default = "^DevOps-Root"
}

variable "vpc_name_regex" {
  type    = string
  default = "^DevOps-VPC"
}

variable "data_disk_name" {
  type    = string
  default = "DevOps-d_gitlab_data"
}

variable "data_disk_category" {
  type    = string
  default = "cloud_essd"
}

variable "data_disk_performance_level" {
  type    = string
  default = "PL0"
}

variable "data_disk_size" {
  type    = string
  default = "200"
}
