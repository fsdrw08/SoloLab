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
  {
    mount = "kvv2_others"
    name  = "vm-day3"
    content = {
      "root_username"               = "core"
      "root_password_hash"          = "$y$j9T$cDLwsV9ODTV31Dt4SuVGa.$FU0eRT9jawPhIV3IV24W7obZ3PaJuBCVp7C9upDCcgD"
      "root_ssh_authorized_key"     = "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key"
      "rootless_username"           = "podmgr"
      "rootless_password_hash"      = "$y$j9T$I4IXP5reKRLKrkwuNjq071$yHlJulSZGzmyppGbdWHyFHw/D8Gl247J2J8P43UnQWA"
      "rootless_ssh_authorized_key" = "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key"
    }
    secret_version = 1
  },
  {
    mount = "kvv2_others"
    name  = "otf"
    content = {
      "secret"     = "6b07b57377755b07cf61709780ee7484"
      "site_token" = "P@ssw0rd"
    }
    secret_version = 1
  },
]
