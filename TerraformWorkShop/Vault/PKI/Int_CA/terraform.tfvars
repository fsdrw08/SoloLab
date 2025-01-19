prov_vault = {
  schema          = "https"
  address         = "vault.day1.sololab:8200"
  token           = "95eba8ed-f6fc-958a-f490-c7fd0eda5e9e"
  skip_tls_verify = true
}

vault_pki = {
  secret_engine = {
    path                    = "pki/day1"
    description             = "PKI engine hosting intermediate CA day1 v1 for sololab"
    default_lease_ttl_years = 3
    max_lease_ttl_years     = 3
  }
  role = {
    name = "IntCA-Day1-v1-role-default"
    # https://developer.hashicorp.com/vault/api-docs/secret/pki#ext_key_usage
    # https://pkg.go.dev/crypto/x509#ExtKeyUsage
    ext_key_usage = [
      "ServerAuth",
      "ClientAuth"
    ]
    ttl_years        = 3
    key_type         = "rsa"
    key_bits         = 4096
    allow_ip_sans    = true
    allowed_domains  = ["day1.sololab", "day1.service.consul"]
    allow_subdomains = true
    allow_any_name   = true
  }
  ca = {
    internal_sign = {
      backend     = "pki/root"
      common_name = "Sololab Intermediate CA Day1"
      ttl_years   = 5
    }
  }
  issuer = {
    name                           = "IntCA-Day1-v1"
    revocation_signature_algorithm = "SHA256WithRSA"
  }
}
