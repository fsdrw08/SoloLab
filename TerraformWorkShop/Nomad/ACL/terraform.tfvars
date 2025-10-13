prov_nomad = {
  address     = "https://nomad.day1.sololab"
  skip_verify = true
}

prov_vault = {
  address         = "https://vault.day1.sololab"
  token           = "95eba8ed-f6fc-958a-f490-c7fd0eda5e9e"
  skip_tls_verify = true
}

policies = [
  {
    name        = "admin"
    description = "admin policy"
    rules       = <<-EOT
      namespace "*" {
        policy = "write"
      }

      node {
        policy = "write"
      }

      agent {
        policy = "write"
      }

      operator {
        policy = "write"
      }

      quota {
        policy = "write"
      }

      # this is a host_volume rule, with a wildcard label
      host_volume "*" {
        policy = "write"
      }

      plugin {
        policy = "write"
      }
    EOT
  },
  {
    name        = "node-write"
    description = "Policy for nomad node write action"
    rules       = <<-EOT
      node {
        policy = "write"
      }
    EOT
  },
]

roles = [
  {
    name        = "management"
    description = "management token (token-management)"
    token = {
      type = "management"
      store = {
        vault_kvv2_path = "kvv2-nomad"
      }
    }
  },
  {
    name                  = "admin"
    description           = "admin role"
    policy_names          = ["admin"]
    auth_binding_selector = "\"app-nomad-admin\" in list.roles"
  },
  {
    name         = "node-write"
    description  = "Role of nomad node (token-node_write)"
    policy_names = ["node-write"]
    token = {
      store = {
        vault_kvv2_path = "kvv2-nomad"
      }
    }
  },
]
