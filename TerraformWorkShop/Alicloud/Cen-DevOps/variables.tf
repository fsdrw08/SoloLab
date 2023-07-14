variable "cen_name" {
  type    = string
  default = "DevOps_CEN"
}

variable "bandwidth" {
  description = "The bandwidth in Mbps of the bandwidth package. Cannot be less than 2Mbps."
  type        = number
  default     = 5
}

variable "cen_bandwidth_package_name" {
  description = "The name of the bandwidth package. Defaults to null."
  type        = string
  default     = "DevOps_CEN_BP"
}

variable "geographic_region_a_id" {
  type    = string
  default = "China"
}

variable "geographic_region_b_id" {
  type    = string
  default = "Asia-Pacific"
}

variable "payment_type" {
  type    = string
  default = "PostPaid"
}

variable "period" {
  description = "The purchase period in month. Valid value: 1, 2, 3, 6, 12. Default to 1."
  type        = number
  default     = 1
}

# variable "child_instances" {
#   description = "CEN child instances infomation"
#   type = map(object({
#     id        = string
#     region_id = string
#     type      = string
#   }))

#   default = {
#     "AP_SG" = {
#       id
#     }
#   }
# }
