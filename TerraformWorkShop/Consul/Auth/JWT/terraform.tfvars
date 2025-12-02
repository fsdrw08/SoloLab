prov_vault = {
  address         = "https://vault.day0.sololab"
  token           = "95eba8ed-f6fc-958a-f490-c7fd0eda5e9e"
  skip_tls_verify = true
}

prov_consul = {
  scheme         = "https"
  address        = "consul.day1.sololab"
  datacenter     = "dc1"
  token          = "e95b599e-166e-7d80-08ad-aee76e7ddf19"
  insecure_https = true
}

jwt_auth_configs = [
  {
    name = "nomad-workloads"
    config = {
      JWKSURL        = "https://nomad.day1.sololab/.well-known/jwks.json"
      BoundAudiences = ["consul.io"]
      ClaimMappings = {
        nomad_namespace = "nomad_namespace"
        nomad_job_id    = "nomad_job_id"
        nomad_task      = "nomad_task"
        nomad_service   = "nomad_service"
      }
    }
  },
  # {
  #   name = "vault-jwt"
  #   config = {
  #     JWKSURL        = "https://vault.day0.sololab/v1/identity/oidc/.well-known/keys"
  #     BoundAudiences = ["consul-jwt-auth"]
  #     BoundIssuer    = "https://vault.day0.sololab/v1/identity/oidc"
  #     ClaimMappings = {
  #       username = "username"
  #     }
  #     ListClaimMappings = {
  #       groups = groups
  #     }
  #   }
  # },
]

acl_binding_rules = [
  # https://github.com/tristanmorgan/nomad-test/blob/a622eb3a72c3688b4c9bb77853b457bb549930fe/terraform/nomad_workloads.tf#L21
  # https://developer.hashicorp.com/nomad/tutorials/integrate-consul/consul-acl#create-a-consul-acl-binding-rule-for-nomad-services
  # Consul ACL binding rule for Nomad services
  {
    iac_key     = "nomad_service"
    auth_name   = "nomad-workloads"
    bind_type   = "service"
    bind_name   = "$${value.nomad_service}"
    description = "Binding rule for services registered from Nomad"
    selector    = "\"nomad_service\" in value"
  },
  # https://developer.hashicorp.com/nomad/tutorials/integrate-consul/consul-acl#configure-consul-for-tasks-workload-identities
  # Consul ACL binding rule for Nomad tasks
  {
    iac_key     = "nomad_task"
    auth_name   = "nomad-workloads"
    bind_type   = "role"
    bind_name   = "$${value.nomad_task}"
    description = "Binding rule for Nomad tasks"
    selector    = "\"nomad_task\" in value"
  },
  # {
  #   auth_name   = "vault-jwt"
  #   bind_type   = "role"
  #   bind_name   = "consul_admin"
  #   description = "Binding consul role \"consul_admin\" to \"App-Consul-Admin\" which mention in the claim \"group\" field"
  #   selector    = "\"App-Consul-Admin\" in list.groups"
  # },
  # {
  #   auth_name   = "vault-jwt"
  #   bind_type   = "role"
  #   bind_name   = "consul_user"
  #   description = "Binding consul role \"consul_user\" to \"App-Consul-User\" which mention in the claim \"group\" field"
  #   selector    = "\"App-Consul-User\" in list.groups"
  # },

]
