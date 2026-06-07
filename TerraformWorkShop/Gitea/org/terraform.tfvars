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
    iac_id = "27beb241"
    name   = "sololab"
    repositories = [
      {
        iac_id    = "42989f91"
        name      = "week1-infra"
        auto_init = false
        private   = false
      }
    ]
  }
]
