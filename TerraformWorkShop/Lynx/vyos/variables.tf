variable "prov_lynx" {
  type = object({
    api_url = string
    api_key = string
  })
}

variable "users" {
  type = list(object({
    iac_id    = string
    name      = string
    email     = string
    role      = optional(string, "regular") # regular / super
    password  = string
    member_of = optional(list(string), null)
  }))
}

# variable "teams" {
#   type = list(object({
#     iac_id      = string
#     name        = string
#     slug        = string
#     description = optional(string, null)
#   }))
# }
