variable "prov_lynx" {
  type = object({
    api_url = string
    api_key = string
  })
}

variable "users" {
  type = list(object({
    iac_id   = string
    name     = string
    email    = string
    role     = optional(string, "regular") # regular / super
    password = string
    # member_of_teams = optional(list(string), null)
  }))
  description = "one user can be assigned to multi teams"
}

variable "teams" {
  type = list(object({
    iac_id      = string
    name        = string
    slug        = optional(string, null)
    description = optional(string, "no description")
    members     = list(string)
    # member_of_projects = optional(list(string), null)
  }))
  description = <<-EOT
    one team can have multi users, 
    one team can be assigned to multi projects.
  EOT
}

variable "projects" {
  type = list(object({
    iac_id      = string
    name        = string
    slug        = optional(string, null)
    description = optional(string, "no description")
    team        = string
    environments = optional(
      list(object({
        iac_id   = string
        name     = string
        slug     = optional(string, null)
        username = string
        secret   = string
      })),
      null
    )
  }))
  description = <<-EOT
    one project can only have one team,
    one project can have multi environments.
  EOT
}
