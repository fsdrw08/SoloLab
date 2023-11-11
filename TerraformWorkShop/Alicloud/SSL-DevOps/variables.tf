variable "resource_group_name_regex" {
  type    = string
  default = "^DevOps-Root"
}

variable "acme_reg_email" {
  description = "E-mail associated with certificate generation."
  type        = string
}

variable "domains" {
  description = "Map of common names to alternative names to create ACME certificates. Module supports wildcard certificates, common name does not need to be included in alternative names."
  type        = map(list(string))
}

variable "acme_min_days_remaining" {
  type        = number
  description = "Number of days remaining when terraform apply will automatically renew the certificate. (default: 30)"
  default     = 30
}

variable "ALICLOUD_ACCESS_KEY" {
  description = "Access key ID"
  type        = string
}

variable "ALICLOUD_SECRET_KEY" {
  description = "Access Key secret."
  type        = string
}
