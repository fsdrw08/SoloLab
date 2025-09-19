variable "prov_tfe" {
  type = object({
    hostname        = optional(string, "app.terraform.io")
    token           = string
    ssl_skip_verify = optional(bool, false)
  })
}

variable "organizations" {
  type = list(object({
    iac_id = string
    name   = string
    email  = string
  }))
}

variable "workspaces" {
  type = list(object({
    iac_id       = string
    name         = string
    organization = string
  }))
}
