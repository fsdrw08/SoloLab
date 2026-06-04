variable "prov_vault" {
  type = object({
    address         = string
    skip_tls_verify = optional(bool, false)
    token           = optional(string, null)
  })
}

variable "prov_tfe" {
  type = object({
    hostname        = optional(string, "app.terraform.io")
    ssl_skip_verify = bool
    token_plaintext = optional(string, null)
    token_reference = optional(
      object({
        vault_kvv2 = object({
          mount = string
          name  = string
          key   = string
        })
    }), null)
  })
}

variable "organizations" {
  type = list(object({
    iac_id                              = string
    name                                = string
    email                               = string
    owners_team_saml_role_id            = optional(string, null)
    speculative_plan_management_enabled = optional(bool, null)
    teams = list(object({
      iac_id = string
      name   = string

      allow_member_token_management = optional(bool, true)
      members                       = optional(list(string), [])
      organization_access = object({
        read_workspaces            = optional(bool, null)
        read_projects              = optional(bool, null)
        manage_policies            = optional(bool, null)
        manage_policy_overrides    = optional(bool, null)
        manage_workspaces          = optional(bool, null)
        manage_vcs_settings        = optional(bool, null)
        manage_providers           = optional(bool, null)
        manage_modules             = optional(bool, null)
        manage_run_tasks           = optional(bool, null)
        manage_projects            = optional(bool, null)
        manage_membership          = optional(bool, null)
        manage_organization_access = optional(bool, null)
        access_secret_teams        = optional(bool, null)
        manage_agent_pools         = optional(bool, null)
      })
    }))
    workspaces = list(object({
      iac_id                = string
      name                  = string
      file_triggers_enabled = optional(bool, true)
      execution_mode        = string
      agent_pool_id         = optional(string, null)
      team_access = optional(list(object({
        team_iac_id = string
        # Type of fixed access to grant. Valid values are admin, read, plan, or write.
        # To use custom permissions, use a permissions block instead.
        # This value must not be provided if permissions is provided.
        access = optional(string, null)
        permissions = optional(object({
          # The permission to grant the team on the workspace's runs. Valid values are read, plan, or apply.
          runs = string
          # The permission to grant the team on the workspace's variables. Valid values are none, read, or write.
          variables = string
          # The permission to grant the team on the workspace's state versions. Valid values are none, read, read-outputs, or write.
          state_versions = string
          # The permission to grant the team on the workspace's generated Sentinel mocks, Valid values are none or read.
          sentinel_mocks = string
          # Boolean determining whether or not to grant the team permission to manually lock/unlock the workspace.
          workspace_locking = bool
          # Boolean determining whether or not to grant the team permission to manage workspace run tasks.
          run_tasks = bool
        }), null)
      })), null)
    }))
  }))
}
