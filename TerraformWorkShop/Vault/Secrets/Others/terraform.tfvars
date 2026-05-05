prov_vault = {
  address         = "https://vault.day1.sololab"
  skip_tls_verify = true
}

secrets = [
  {
    mount = "kvv2_others"
    name  = "git-repo-operator"
    content = {
      "username" = "000"
      "password" = "P@ssw0rd"
    }
    secret_version = 1
  },
]
