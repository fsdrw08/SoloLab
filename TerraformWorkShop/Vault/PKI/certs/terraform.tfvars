prov_vault = {
  schema          = "https"
  address         = "vault.day1.sololab:8200"
  token           = "95eba8ed-f6fc-958a-f490-c7fd0eda5e9e"
  skip_tls_verify = true
}

vault_kvv2 = {
  secret_engine = {
    path = "kvv2/certs"
  }
  data_key_name = {
    ca          = "ca"
    cert        = "cert"
    private_key = "private_key"
  }
}

vault_certs = [
  {
    secret_engine = {
      backend   = "pki/day1"
      role_name = "IntCA-Day1-v1-role-default"
    }
    ttl_years   = 3
    common_name = "opendj.day1.sololab"
  },
  {
    secret_engine = {
      backend   = "pki/day1"
      role_name = "IntCA-Day1-v1-role-default"
    }
    ttl_years   = 3
    common_name = "consul.day1.sololab"
    alt_names = [
      "consul.service.consul",
      "server.dc1.consul",
      "localhost"
    ]
  },
  {
    secret_engine = {
      backend   = "pki/day1"
      role_name = "IntCA-Day1-v1-role-default"
    }
    ttl_years   = 3
    common_name = "traefik.day1.sololab"
    alt_names = [
      "traefik.service.consul",
    ]
  },
  {
    secret_engine = {
      backend   = "pki/day1"
      role_name = "IntCA-Day1-v1-role-default"
    }
    ttl_years   = 3
    common_name = "nomad.day1.sololab"
    alt_names = [
      "nomad.service.consul",
    ]
  },
]
