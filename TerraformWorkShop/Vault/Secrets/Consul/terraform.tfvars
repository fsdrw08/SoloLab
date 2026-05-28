prov_vault = {
  address         = "https://vault.day1.sololab"
  skip_tls_verify = true
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
