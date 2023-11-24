variable "resource_group_name_regex" {
  type    = string
  default = "^DevOps-Root"
}

# https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/eip_address
variable "eip" {
  type = map(object({
    address_name         = string
    payment_type         = string
    internet_charge_type = string
    auto_pay             = optional(bool)
    isp                  = string
    bandwidth            = number
    description          = optional(string)
  }))
}
