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
        bind_name   = "role-nomad_task"
        bind_type   = "role"
        description = "Binding rule for Nomad tasks"
        selector    = "\"nomad_task\" in value"
      },
    ]
    roles = [
      # https://developer.hashicorp.com/nomad/tutorials/integrate-consul/consul-acl#create-a-consul-acl-role-for-nomad-tasks
      {
        name         = "role-nomad_task"
        description  = "Role of nomad tasks"
        policy_names = ["policy-nomad_task"]
      },
    ]
    policies = [
      {
        name  = "policy-nomad_task"
        rules = <<-EOT
          agent_prefix "" {
            policy = "read"
          }

          node_prefix "" {
            policy = "write"
          }

          service_prefix "" {
            policy = "write"
          }
        EOT
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
  #       groups = "groups"
  #     }
  #   }
  #   binding_rules = [
  #     {
  #       iac_id      = "consul_admin"
  #       bind_name   = "role-consul_admin"
  #       bind_type   = "role"
  #       description = "Binding consul role \"consul_admin\" to \"App-Consul-Admin\" which mention in the claim \"group\" field"
  #       selector    = "\"App-Consul-Admin\" in list.groups"
  #     },
  #     {
  #       iac_id      = "consul_user"
  #       bind_name   = "role-consul_user"
  #       bind_type   = "role"
  #       description = "Binding consul role \"consul_user\" to \"App-Consul-User\" which mention in the claim \"group\" field"
  #       selector    = "\"App-Consul-User\" in list.groups"
  #     },
  #   ]
  #   roles = [
  #     {
  #       name         = "role-consul_admin"
  #       description  = "Role of consul admin"
  #       policy_names = ["global-management"]
  #     },
  #     {
  #       name         = "role-consul_user"
  #       description  = "Role of consul user"
  #       policy_names = ["builtin/global-read-only"]
  #     },
  #   ]
  # },
]
