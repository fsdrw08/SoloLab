prov_vault = {
  address         = "https://vault.day1.sololab"
  skip_tls_verify = true
}

prov_gitea = {
  base_url = "https://gitea.day4.sololab"
  insecure = true
  credential = {
    "username" = {
      plaintext = "terraform"
    }
    "password" = {
      vault_kvv2 = {
        mount = "kvv2_others"
        name  = "app-gitea"
        key   = "iac-credential-password"
      }
    }
  }
}

users = [
  {
    iac_id               = "d57107bf"
    email                = "atlentis@mail.sololab"
    login_name           = "atlentis"
    password_version     = 1
    username             = "atlentis"
    must_change_password = false
  }
]
