prov_vault = {
  address         = "https://vault.day1.sololab:8200"
  token           = "95eba8ed-f6fc-958a-f490-c7fd0eda5e9e"
  skip_tls_verify = true
}

prov_consul = {
  scheme         = "https"
  address        = "consul.day1.sololab:8501"
  datacenter     = "dc1"
  token          = "e95b599e-166e-7d80-08ad-aee76e7ddf19"
  insecure_https = true
}

policy_bindings = [
  {
    # https://developer.hashicorp.com/nomad/docs/integrations/consul/acl#nomad-agents
    name        = "nomad_server"
    description = "Policy for nomad server to interact with Consul"
    rules       = <<-EOT
      agent_prefix "" {
        policy = "read"
      }

      node_prefix "" {
        policy = "write"
      }

      service_prefix "" {
        policy = "write"
      }

      acl  = "write"
      mesh = "write"
    EOT
    token = {
      vault_kvv2_path = "kvv2/consul"
    }
  },
  {
    # https://developer.hashicorp.com/nomad/docs/integrations/consul/acl#nomad-agents
    name        = "nomad_client"
    description = "Policy for nomad client to interact with Consul"
    rules       = <<-EOT
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
    token = {
      vault_kvv2_path = "kvv2/consul"
    }
  },
  {
    name        = "prometheus"
    description = "Policy for Prometheus to read node information"
    rules       = <<-EOT
      node_prefix "" {
        policy = "read"
      }

      agent_prefix "" {
        policy = "read"
      }

      service_prefix "" {
        policy = "read"
      }
    EOT
    token = {
      vault_kvv2_path = "kvv2/consul"
    }
  },
  {
    name        = "consul_client"
    description = "Policy for consul client to work with consul server"
    rules       = <<-EOT
      node_prefix "" {
        policy = "write"
      }
      service_prefix "" {
        policy = "write"
      }
      key_prefix "" {
        policy = "read"
      }
      agent_prefix "" {
        policy = "read"
      }
    EOT
    token = {
      vault_kvv2_path = "kvv2/consul"
    }
  },
]
