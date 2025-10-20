prov_vault = {
  schema          = "https"
  address         = "vault.day1.sololab:8200"
  token           = "95eba8ed-f6fc-958a-f490-c7fd0eda5e9e"
  skip_tls_verify = true
}

vault_kvv2 = {
  secret_engine = {
    path = "kvv2-certs"
  }
  data_key_name = {
    ca          = "ca"
    cert        = "cert"
    private_key = "private_key"
  }
}

vault_certs = [
  # consul server cert
  {
    secret_engine = {
      backend   = "pki-sololab_day1"
      role_name = "IntCA-Day1-v1-role-default"
    }
    ttl_years   = 3
    common_name = "consul.service.consul"
    alt_names = [
      "consul.day1.sololab",
      "server.dc1.consul",
      "localhost"
    ]
  },
  # day1 and consul service wild card cert hosting in reverse proxy
  {
    secret_engine = {
      backend   = "pki-sololab_day1"
      role_name = "IntCA-Day1-v1-role-default"
    }
    ttl_years   = 3
    common_name = "*.service.consul"
    alt_names = [
      "*.day1.sololab"
    ]
  },
  {
    secret_engine = {
      backend   = "pki-sololab_day1"
      role_name = "IntCA-Day1-v1-role-default"
    }
    ttl_years   = 3
    common_name = "nomad.day1.sololab"
    alt_names = [
      "nomad.service.consul",
    ]
  },
  # https://developer.hashicorp.com/nomad/tutorials/archive/security-enable-tls#agent-certificates
  # https://developer.hashicorp.com/nomad/tutorials/integrate-vault/vault-pki-nomad#create-and-populate-the-templates-directory
  # https://github.com/livioribeiro/nomad-lxd-terraform/blob/0c792716c9824c4c59de349d27b6aa1d1c16b09d/certs.tf#L197
  {
    secret_engine = {
      backend   = "pki-sololab_day1"
      role_name = "IntCA-Day1-v1-role-default"
    }
    ttl_years   = 3
    common_name = "client.global.nomad"
    alt_names = [
      "nomad-client.service.consul",
      "localhost",
    ]
    ip_sans = ["127.0.0.1"]
  },
  # {
  #   secret_engine = {
  #     backend   = "pki-sololab_day1"
  #     role_name = "IntCA-Day1-v1-role-default"
  #   }
  #   ttl_years   = 3
  #   common_name = "minio-api.day1.sololab"
  #   alt_names = [
  #     "minio-console.day1.sololab",
  #   ]
  # },
  # {
  #   secret_engine = {
  #     backend   = "pki-sololab_day1"
  #     role_name = "IntCA-Day1-v1-role-default"
  #   }
  #   ttl_years   = 3
  #   common_name = "grafana.day1.sololab"
  # },
  # {
  #   secret_engine = {
  #     backend   = "pki-sololab_day1"
  #     role_name = "IntCA-Day1-v1-role-default"
  #   }
  #   ttl_years   = 3
  #   common_name = "loki.day1.sololab"
  # },
  # {
  #   secret_engine = {
  #     backend   = "pki-sololab_day1"
  #     role_name = "IntCA-Day1-v1-role-default"
  #   }
  #   ttl_years   = 3
  #   common_name = "alloy.day1.sololab"
  #   alt_names = [
  #     "alloy.day0.sololab",
  #   ]
  # },
  # {
  #   secret_engine = {
  #     backend   = "pki-sololab_day1"
  #     role_name = "IntCA-Day1-v1-role-default"
  #   }
  #   ttl_years   = 3
  #   common_name = "prometheus.day1.sololab"
  # },
  # {
  #   secret_engine = {
  #     backend   = "pki-sololab_day1"
  #     role_name = "IntCA-Day1-v1-role-default"
  #   }
  #   ttl_years   = 3
  #   common_name = "redis-insight.day1.sololab"
  # },
]
