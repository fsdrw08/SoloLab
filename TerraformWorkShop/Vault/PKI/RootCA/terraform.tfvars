prov_vault = {
  schema          = "https"
  address         = "vault.day1.sololab:8200"
  token           = "95eba8ed-f6fc-958a-f490-c7fd0eda5e9e"
  skip_tls_verify = true
}

vault_pki = {
  secret_engine = {
    path                    = "pki/root"
    description             = "PKI engine hosting root CA v1 for sololab"
    default_lease_ttl_years = 5
    max_lease_ttl_years     = 5
  }
  role = {
    name             = "RootCA-v1-role-default"
    ttl_years        = 5
    key_type         = "rsa"
    key_bits         = 4096
    allow_ip_sans    = true
    allowed_domains  = ["sololab", "service.consul"]
    allow_subdomains = true
    allow_any_name   = true
  }
  ca = {
    external_import = {
      # ref_cert_bundle_path = "../../../TLS/RootCA/RootCA_bundle.pem"
      ref_cert_bundle_path = ""
    }
  }
  issuer = {
    name                           = "RootCA-v1"
    revocation_signature_algorithm = "SHA256WithRSA"
  }
}
