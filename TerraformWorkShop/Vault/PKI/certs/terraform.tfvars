prov_vault = {
  schema          = "https"
  address         = "vault.day0.sololab"
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
    common_name = "*.day1.sololab"
  },
  {
    secret_engine = {
      backend   = "pki/day1"
      role_name = "IntCA-Day1-v1-role-default"
    }
    ttl_years   = 3
    common_name = "minio-api.day1.sololab"
    alt_names = [
      "minio-console.day1.sololab",
    ]
  },
  {
    secret_engine = {
      backend   = "pki/day1"
      role_name = "IntCA-Day1-v1-role-default"
    }
    ttl_years   = 3
    common_name = "grafana.day1.sololab"
  },
  {
    secret_engine = {
      backend   = "pki/day1"
      role_name = "IntCA-Day1-v1-role-default"
    }
    ttl_years   = 3
    common_name = "loki.day1.sololab"
  },
  {
    secret_engine = {
      backend   = "pki/day1"
      role_name = "IntCA-Day1-v1-role-default"
    }
    ttl_years   = 3
    common_name = "alloy.day1.sololab"
    alt_names = [
      "alloy.day0.sololab",
    ]
  },
  {
    secret_engine = {
      backend   = "pki/day1"
      role_name = "IntCA-Day1-v1-role-default"
    }
    ttl_years   = 3
    common_name = "prometheus.day1.sololab"
  },
  # {
  #   secret_engine = {
  #     backend   = "pki/day1"
  #     role_name = "IntCA-Day1-v1-role-default"
  #   }
  #   ttl_years   = 3
  #   common_name = "nomad.day1.sololab"
  #   alt_names = [
  #     "nomad.service.consul",
  #   ]
  # },
]
