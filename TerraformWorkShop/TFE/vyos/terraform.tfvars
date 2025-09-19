prov_tfe = {
  hostname = "otf.vyos.sololab"
  token    = "P@ssw0rd"
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
    name         = "vyos"
    organization = "sololab"
  }
]
