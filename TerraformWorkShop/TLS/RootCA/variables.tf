variable "root_ca" {
  type = object({
    key = object({
      algorithm   = string
      ecdsa_curve = optional(string, null)
      rsa_bits    = optional(string, null)
    })
    cert = object({
      subject = object({
        common_name         = optional(string, null)
        country             = optional(string, null)
        locality            = optional(string, null)
        organization        = optional(string, null)
        organizational_unit = optional(string, null)
        postal_code         = optional(string, null)
        province            = optional(string, null)
        serial_number       = optional(string, null)
        street_address      = optional(list(string), null)
      })
      validity_period_hours = number
      allowed_uses          = list(string)
    })
  })
}

variable "int_ca" {
  type = object({
    key = object({
      algorithm   = string
      ecdsa_curve = optional(string, null)
      rsa_bits    = optional(string, null)
    })
    cert = object({
      subject = object({
        common_name         = optional(string, null)
        country             = optional(string, null)
        locality            = optional(string, null)
        organization        = optional(string, null)
        organizational_unit = optional(string, null)
        postal_code         = optional(string, null)
        province            = optional(string, null)
        serial_number       = optional(string, null)
        street_address      = optional(list(string), null)
      })
      validity_period_hours = number
      allowed_uses          = list(string)
    })
  })
}

variable "certs" {
  type = list(object({
    name = string
    key = object({
      algorithm   = string
      ecdsa_curve = optional(string, null)
      rsa_bits    = optional(string, null)
    })
    cert = object({
      dns_names             = list(string)
      ip_addresses          = optional(list(string), null)
      subject               = map(string)
      validity_period_hours = number
      allowed_uses          = optional(list(string), null)
    })
  }))
}
