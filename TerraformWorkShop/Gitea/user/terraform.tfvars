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

users = [
  {
    iac_id               = "d57107bf"
    email                = "gitea-bot-atlantis@mail.sololab"
    login_name           = "bot-atlantis"
    password_version     = 1
    username             = "bot-atlantis"
    must_change_password = false
  }
]
