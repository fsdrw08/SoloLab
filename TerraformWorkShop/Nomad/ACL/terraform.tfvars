prov_nomad = {
  address     = "https://nomad.day1.sololab:4646"
  skip_verify = true
}

prov_vault = {
  address         = "https://vault.day1.sololab:8200"
  token           = "95eba8ed-f6fc-958a-f490-c7fd0eda5e9e"
  skip_tls_verify = true
}

policy_bindings = [

  # {
  #   # https://developer.hashicorp.com/nomad/docs/integrations/consul/acl#nomad-agents
  #   name        = "admin"
  #   description = "Policy for nomad admin"
  #   rules       = <<-EOT
  #     namespace "*" {
  #       policy = "write"
  #     }

  #     node {
  #       policy = "write"
  #     }

  #     agent {
  #       policy = "write"
  #     }

  #     operator {
  #       policy = "write"
  #     }

  #     quota {
  #       policy = "write"
  #     }

  #     # this is a host_volume rule, with a wildcard label
  #     host_volume "*" {
  #       policy = "write"
  #     }

  #     plugin {
  #       policy = "write"
  #     }
  #   EOT
  #   token = {
  #     vault_kvv2_path = "kvv2/nomad"
  #   }
  # },
  {
    # https://developer.hashicorp.com/nomad/docs/integrations/consul/acl#nomad-agents
    name        = "node-write"
    description = "Policy for nomad node write action"
    rules       = <<-EOT
      node {
        policy = "write"
      }
    EOT
    token = {
      vault_kvv2_path = "kvv2/nomad"
    }
  },
]
