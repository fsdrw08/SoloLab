prov_vault = {
  address         = "https://vault.day1.sololab"
  skip_tls_verify = true
}

prov_tfe = {
  hostname        = "otf.day4.sololab"
  ssl_skip_verify = true
  token_reference = {
    mount = "kvv2_others"
    name  = "otf"
    key   = "site_token"
  }
}

organizations = [
  {
    iac_id = "1bed406a"
    name   = "sololab"
    email  = "root@mail.sololab"
  }
]

workspaces = [
  {
    iac_id       = "d8c91cc6"
    name         = "day5"
    organization = "sololab"
  }
]
