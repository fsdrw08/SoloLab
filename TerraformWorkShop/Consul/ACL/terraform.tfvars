prov_vault = {
  address         = "https://vault.day1.sololab:8200"
  token           = "95eba8ed-f6fc-958a-f490-c7fd0eda5e9e"
  skip_tls_verify = true
}

prov_consul = {
  scheme         = "https"
  address        = "consul.service.consul:8501"
  datacenter     = "dc1"
  token          = "e95b599e-166e-7d80-08ad-aee76e7ddf19"
  insecure_https = true
}

policies = [
  {
    # https://developer.hashicorp.com/nomad/docs/integrations/consul/acl#nomad-agents
    name        = "consul_dns"
    description = "Policy for traefik proxy consul catalog provoider to read service"
    rules       = <<-EOT
      agent_prefix "" {
        policy = "read"
      }
      node_prefix "" {
        policy = "read"
      }
      service_prefix "" {
        policy = "read"
      }
    EOT
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
  },
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
  },
  {
    # https://developer.hashicorp.com/nomad/docs/integrations/consul/acl#nomad-agents
    name        = "nomad_task"
    description = "Policy for nomad workload(task) to interact with Consul"
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
  },
]

roles = [
  {
    name         = "consul_dns"
    description  = "Role to read node and service"
    policy_names = ["consul_dns"]
    token_store = {
      vault_kvv2_path = "kvv2_consul"
    }
  },
  {
    name         = "consul_client"
    description  = "Role of consul client"
    policy_names = ["consul_client"]
    token_store = {
      vault_kvv2_path = "kvv2_consul"
    }
  },
  {
    name         = "nomad_server"
    description  = "Role of nomad server"
    policy_names = ["nomad_server"]
    token_store = {
      vault_kvv2_path = "kvv2_consul"
    }
  },
  {
    name         = "nomad_client"
    description  = "Role of nomad client"
    policy_names = ["nomad_client"]
    token_store = {
      vault_kvv2_path = "kvv2_consul"
    }
  },
  {
    name         = "nomad_task"
    description  = "Role of nomad tasks"
    policy_names = ["nomad_task"]
  },
  # {
  #   name         = "consul_admin"
  #   description  = "Role of consul admin"
  #   policy_names = ["global-management"]
  # },
  # {
  #   name         = "consul_user"
  #   description  = "Role of consul user"
  #   policy_names = ["builtin/global-read-only"]
  # },
  {
    name         = "prometheus"
    description  = "Role of Prometheus"
    policy_names = ["prometheus"]
    token_store = {
      vault_kvv2_path = "kvv2_consul"
    }
  },
]
