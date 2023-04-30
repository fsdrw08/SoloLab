variable "ldap_insecure_tls" {
  description = "(bool, optional) - If true, skips LDAP server SSL certificate verification - insecure, use with caution!"
  type        = bool
  default     = true
}

variable "ldap_certificate" {
  description = "(string, optional) - CA certificate to use when verifying LDAP server certificate, must be x509 PEM encoded."
  type        = string
  default     = null
}

variable "ldap_bindpass" {
  description = "(string, optional) - Password to use along with binddn when performing user search."
  type        = string
  default     = null
  sensitive   = true
}