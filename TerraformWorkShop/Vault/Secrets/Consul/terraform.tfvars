prov_vault = {
  address         = "https://vault.day1.sololab"
  skip_tls_verify = true
}

consul_secret_backend = {
  scheme         = "https"
  address        = "consul.day2.sololab:8501"
  token          = "e95b599e-166e-7d80-08ad-aee76e7ddf19"
  insecure_https = true
}

consul_roles = [
  # builtin polices: https://developer.hashicorp.com/consul/docs/security/acl/acl-policies#built-in-policies
  {
    name            = "admin"
    consul_policies = ["global-management"]
    ttl             = 3600
    groups_binding  = ["app-consul-admin"]
  },
  {
    name            = "readonly"
    consul_policies = ["builtin/global-read-only"]
    ttl             = 3600
    groups_binding  = ["app-consul-readonly"]
  }
]
