prov_vault = {
  address         = "https://vault.day1.sololab"
  skip_tls_verify = true
}

prov_consul = {
  scheme     = "https"
  address    = "consul.day2.sololab"
  datacenter = "dc1"
  token_reference = {
    vault_kvv2 = {
      mount = "kvv2_consul"
      name  = "token-init_management"
      key   = "token"
    }
  }
  insecure_https = true
}

jwt_auth_configs = [
  {
    name = "nomad-workloads"
    config = {
      JWKSURL        = "https://nomad.day2.sololab/.well-known/jwks.json"
      BoundAudiences = ["consul.io"]
      ClaimMappings = {
        nomad_namespace = "nomad_namespace"
        nomad_job_id    = "nomad_job_id"
        nomad_task      = "nomad_task"
        nomad_service   = "nomad_service"
      }
    }
    binding_rules = [
      {
        iac_id      = "nomad_service"
        bind_name   = "$${value.nomad_service}"
        bind_type   = "service"
        description = "Binding rule for services registered from Nomad"
        selector    = "\"nomad_service\" in value"
      },
      {
        iac_id      = "nomad_task"
        bind_name   = "nomad-tasks-$${value.nomad_namespace}"
        bind_type   = "role"
        description = "Binding rule for Nomad tasks"
        selector    = "\"nomad_task\" in value"
      },
    ]
  },
  # {
  #   name = "vault-jwt"
  #   config = {
  #     JWKSURL        = "https://vault.day1.sololab/v1/identity/oidc/.well-known/keys"
  #     BoundAudiences = ["consul-jwt-auth"]
  #     BoundIssuer    = "https://vault.day1.sololab/v1/identity/oidc"
  #     ClaimMappings = {
  #       username = "username"
  #     }
  #     ListClaimMappings = {
  #       groups = groups
  #     }
  #   }
  #   binding_rules = [
  #     {
  #       iac_id      = "consul_admin"
  #       bind_name   = "consul_admin"
  #       bind_type   = "role"
  #       description = "Binding consul role \"consul_admin\" to \"App-Consul-Admin\" which mention in the claim \"group\" field"
  #       selector    = "\"App-Consul-Admin\" in list.groups"
  #     },
  #     {
  #       iac_id      = "consul_user"
  #       bind_name   = "consul_user"
  #       bind_type   = "role"
  #       description = "Binding consul role \"consul_user\" to \"App-Consul-User\" which mention in the claim \"group\" field"
  #       selector    = "\"App-Consul-User\" in list.groups"
  #     },
  #   ]
  # },
]
