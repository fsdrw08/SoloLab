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

repositories = [
  {
    org_name          = "standalone-lab"
    iac_id            = "93b6d451"
    name              = "sololab"
    default_branch    = "main"
    has_issues        = true
    has_pull_requests = true
    mirror            = false
    private           = false
    webhooks = [
      {
        iac_id        = "dd410de1"
        active        = true
        branch_filter = "*"
        content_type  = "json"
        # https://www.runatlantis.io/docs/configuring-webhooks.html#gitea
        # https://docs.gitea.com/usage/repository/webhooks#events
        events = [
          "push",
          "issue_comment",
          "pull_request",
          "pull_request_comment",
          "pull_request_review",
          "pull_request_sync"
        ]
        type = "gitea"
        url  = "https://atlantis.day4.sololab/events"
        secret = {
          vault_kvv2 = {
            mount = "kvv2_others"
            name  = "app-atlantis"
            key   = "gitea_webhook_secret"
          }
        }
      }
    ]
  }
]
