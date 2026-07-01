prov_vault = {
  address         = "https://vault.day1.sololab"
  skip_tls_verify = true
}

prov_gitea = {
  base_url = "https://gitea.day4.sololab"
  insecure = true
  credential = {
    "username" = {
      plaintext = "admin"
    }
    "password" = {
      vault_kvv2 = {
        mount = "kvv2_others"
        name  = "app-gitea"
        key   = "admin_password"
      }
    }
  }
}

organizations = [
  {
    iac_id = "1d285370"
    name   = "fsdrw08"
    repositories = [
      {
        iac_id    = "42989f91"
        name      = "sololab"
        auto_init = false
        private   = false
      }
    ]
  },
  {
    iac_id = "27beb241"
    name   = "standalone-lab"
    teams = [
      {
        iac_id                   = "daacde20"
        name                     = "atlantis"
        description              = "atlantis operator"
        include_all_repositories = true
        permission               = "write"
        units                    = <<-EOF
          repo.code,
          repo.ext_issues,
          repo.pulls
        EOF
        members                  = ["bot-atlantis"]
      },
      {
        iac_id                   = "88d9b884"
        name                     = "admin"
        description              = "admin team"
        include_all_repositories = true
        permission               = "write"
        units                    = <<-EOF
          repo.actions
          repo.code
          repo.issues
          repo.ext_issues
          repo.wiki
          repo.ext_wiki
          repo.pulls
          repo.releases
          repo.projects
          repo.ext_wiki
        EOF
        members                  = ["000"]
      }
    ]
    # repositories = [
    #   {
    #     iac_id    = "42989f91"
    #     name      = "sololab"
    #     auto_init = false
    #     private   = false
    #     webhooks = [
    #       {
    #         iac_id        = "0aa03a05"
    #         active        = true
    #         branch_filter = "*"
    #         content_type  = "json"
    #         # https://www.runatlantis.io/docs/configuring-webhooks.html#gitea
    #         # https://docs.gitea.com/usage/repository/webhooks#events
    #         events = [
    #           "push",
    #           "issue_comment",
    #           "pull_request",
    #           "pull_request_comment",
    #           "pull_request_review",
    #           "pull_request_sync"
    #         ]
    #         type = "gitea"
    #         url  = "https://atlantis.day4.sololab/events"
    #         secret = {
    #           vault_kvv2 = {
    #             mount = "kvv2_others"
    #             name  = "app-atlantis"
    #             key   = "gitea_webhook_secret"
    #           }
    #         }
    #       }
    #     ]
    #   }
    # ]
  }
]
