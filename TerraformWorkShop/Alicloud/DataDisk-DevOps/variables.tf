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

variable "data_disks_name" {
  type = list(string)
  default = [
    "DevOps-D_gitlab_data"
  ]
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

variable "data_disk_payment_type" {
  type    = string
  default = "PayAsYouGo"
}
