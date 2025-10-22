prov_vault = {
  schema          = "https"
  address         = "vault.day1.sololab:8200"
  token           = "95eba8ed-f6fc-958a-f490-c7fd0eda5e9e"
  skip_tls_verify = true
}

intermediate_cas = [
  # day1
  {
    secret_engine = {
      path                    = "pki-sololab_day1"
      description             = "PKI engine hosting intermediate CA day1 v1 for sololab"
      default_lease_ttl_years = 3
      max_lease_ttl_years     = 3
    }
    enable_backend_config = true
    csr = {
      root_ca_backend = "pki-sololab_root"
      common_name     = "Sololab Intermediate CA Day1"
      ttl_years       = 5
    }
    issuer = {
      name                           = "IntCA-Day1-v1"
      revocation_signature_algorithm = "SHA256WithRSA"
    }
    roles = [
      {
        name = "IntCA-Day1-v1-role-default"
        # https://developer.hashicorp.com/vault/api-docs/secret/pki#ext_key_usage
        # https://pkg.go.dev/crypto/x509#ExtKeyUsage
        ext_key_usage = [
          "ServerAuth",
          "ClientAuth"
        ]
        ttl_months       = 36
        key_type         = "rsa"
        key_bits         = 4096
        allow_ip_sans    = true
        allowed_domains  = ["sololab", "consul"]
        allow_subdomains = true
        allow_any_name   = true
      },
    ]
    public_fqdn = "vault.day1.sololab"
  },
  # day2
  {
    secret_engine = {
      path                    = "pki-sololab_day2"
      description             = "PKI engine hosting intermediate CA day2+ v1 for sololab"
      default_lease_ttl_years = 3
      max_lease_ttl_years     = 3
    }
    enable_backend_config = true
    csr = {
      root_ca_backend = "pki-sololab_root"
      common_name     = "Sololab Intermediate CA Day2"
      ttl_years       = 5
    }
    issuer = {
      name                           = "IntCA-Day2Plus-v1"
      revocation_signature_algorithm = "SHA256WithRSA"
    }
    roles = [
      {
        name             = "IntCA-Day2Plus-v1-role-acme"
        ttl_months       = 3
        key_type         = "rsa"
        key_bits         = 4096
        allow_ip_sans    = true
        allowed_domains  = ["sololab"]
        allow_subdomains = true
        allow_any_name   = true
      },
    ]
    acme_allowed_roles = ["IntCA-Day2Plus-v1-role-acme"]
    public_fqdn        = "vault.day1.sololab"
  },
  # consul int
  # https://developer.hashicorp.com/consul/tutorials/operate-consul/vault-pki-consul-connect-ca
  # https://developer.hashicorp.com/consul/docs/secure-mesh/certificate/vault
  {
    secret_engine = {
      path                    = "pki-consul_int"
      description             = "PKI engine hosting intermediate CA for consul connect"
      default_lease_ttl_years = 3
      max_lease_ttl_years     = 3
    }
    enable_backend_config = false
  },
]
