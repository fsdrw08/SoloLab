prov_vault = {
  address         = "https://vault.day1.sololab"
  skip_tls_verify = true
}

prov_tfe = {
  hostname        = "otf.day4.sololab"
  ssl_skip_verify = true
  token_reference = {
    vault_kvv2 = {
      mount = "kvv2_others"
      name  = "app-otf"
      key   = "site_token"
    }
  }
}

organizations = [
  {
    iac_id = "1bed406a"
    name   = "sololab"
    email  = "root@mail.sololab"
    teams = [
      {
        iac_id                        = "e6fb5b58"
        name                          = "admin"
        allow_member_token_management = false
        members                       = ["000"]
        organization_access = {
          manage_policies            = true
          manage_policy_overrides    = true
          manage_workspaces          = true
          manage_vcs_settings        = true
          manage_providers           = true
          manage_modules             = true
          manage_run_tasks           = true
          manage_projects            = true
          manage_membership          = true
          manage_organization_access = true
          access_secret_teams        = true
          manage_agent_pools         = true
        }
      }
    ]
    workspaces = [
      {
        iac_id                = "d8c91cc6"
        name                  = "day5"
        file_triggers_enabled = false
        execution_mode        = "local"
        team_access = [
          {
            team_iac_id = "e6fb5b58"
            access      = "admin"
          }
        ]
      }
    ]
  }
]
