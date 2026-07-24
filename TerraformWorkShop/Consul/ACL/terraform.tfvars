prov_vault = {
  address         = "https://vault.day1.sololab"
  skip_tls_verify = true
}

prov_consul = {
  scheme         = "https"
  address        = "consul.day2.sololab:8501"
  insecure_https = true
  datacenter     = "dc1"
  credential = {
    "token" = {
      vault_kvv2 = {
        mount = "kvv2_consul"
        name  = "token-init_management"
        key   = "token"
      }
    }
  }
}

policies = [
  {
    # https://developer.hashicorp.com/nomad/docs/integrations/consul/acl#nomad-agents
    name        = "policy-consul_dns"
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
    name        = "policy-consul_client"
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
    name        = "policy-nomad_server"
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
    name        = "policy-nomad_client"
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
    name        = "policy-prometheus"
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
  {
    name        = "policy-tf_backend"
    description = "Policy for Terraform to read and write state"
    rules       = <<-EOT
      key_prefix "tfstate/" {
        policy = "write"
      }
      
      session_prefix "" {
        policy = "write"
      }
    EOT
  },
]

roles = [
  {
    iac_id       = "63e8c3e9"
    name         = "role-consul_dns"
    description  = "Role to read node and service"
    policy_names = ["policy-consul_dns"]
    token_store = {
      vault_kvv2_path = "kvv2_consul"
    }
  },
  {
    iac_id       = "685da2a6"
    name         = "role-consul_client"
    description  = "Role of consul client"
    policy_names = ["policy-consul_client"]
    token_store = {
      vault_kvv2_path = "kvv2_consul"
    }
  },
  {
    iac_id       = "11e19d4c"
    name         = "role-nomad_server"
    description  = "Role of nomad server"
    policy_names = ["policy-nomad_server"]
    token_store = {
      vault_kvv2_path = "kvv2_consul"
    }
  },
  {
    iac_id       = "95eaad9e"
    name         = "role-nomad_client"
    description  = "Role of nomad client"
    policy_names = ["policy-nomad_client"]
    token_store = {
      vault_kvv2_path = "kvv2_consul"
    }
  },
  {
    iac_id       = "1f88bc0c"
    name         = "role-prometheus"
    description  = "Role of Prometheus"
    policy_names = ["policy-prometheus"]
    token_store = {
      vault_kvv2_path = "kvv2_consul"
    }
  },
  {
    iac_id       = "a65dab9e"
    name         = "role-tf_backend"
    description  = "Role of Terraform"
    policy_names = ["policy-tf_backend"]
    token_store = {
      vault_kvv2_path = "kvv2_consul"
    }
  },
]
