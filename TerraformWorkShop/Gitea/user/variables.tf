variable "prov_vault" {
  type = object({
    address         = string
    skip_tls_verify = optional(bool, false)
    token           = optional(string, null)
  })
}

variable "prov_gitea" {
  type = object({
    base_url    = string
    cacert_file = optional(string, null)
    insecure    = bool
    credential = optional(
      map(object({
        plaintext = optional(string, null)
        vault_kvv2 = optional(
          object({
            mount = string
            name  = string
            key   = string
          }),
          null
        )
      })),
      null
    )
  })
}

variable "users" {
  type = list(object({
    iac_id                    = string
    email                     = string                 # E-Mail Address of the user
    login_name                = string                 # The login name can differ from the username
    password                  = optional(string, null) # Sensitive Password to be set for the user
    password_version          = number
    username                  = string                 # Username of the user to be created
    active                    = optional(bool, null)   # Flag if this user should be active or not
    admin                     = optional(bool, null)   # Flag if this user should be an administrator or not
    allow_create_organization = optional(bool, null)   #
    allow_git_hook            = optional(bool, null)   #
    allow_import_local        = optional(bool, null)   #
    description               = optional(string, null) # A description of the user
    force_password_change     = optional(bool, null)   # Flag if the user defined password should be overwritten or not
    full_name                 = optional(string, null) # Full name of the user
    location                  = optional(string, null) #
    max_repo_creation         = optional(number, null) #
    must_change_password      = optional(bool, null)   # Flag if the user should change the password after first login
    prohibit_login            = optional(bool, null)   # Flag if the user should not be allowed to log in (bot user)
    restricted                = optional(bool, null)   #
    send_notification         = optional(bool, null)   # Flag to send a notification about the user creation to the defined email
    visibility                = optional(string, null) # Visibility of the user. Can be public, limited or private
  }))
}