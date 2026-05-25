prov_vault = {
  address         = "https://vault.day1.sololab"
  skip_tls_verify = true
}

secrets = [
  {
    mount = "kvv2_others"
    name  = "vm-day2"
    content = {
      "root_username"     = "core"
      "root_password"     = "P@ssw0rd"
      "rootless_username" = "podmgr"
      "rootless_password" = "podmgr"
    }
    secret_version = 1
  },
]
