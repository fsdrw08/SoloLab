
variable "vswitch_name" {
  default = "DevOps-Root"
}

variable "vswitch_cidr" {
  default = "172.16.1.0/24"
}

variable "vswitch_description" {
  default = "This resource is managed by terraform"
}

variable "security_group_name" {
  default = "DevOps-Root"
}
