prov_vault = {
  address         = "https://vault.day1.sololab"
  skip_tls_verify = true
}

prov_nomad = {
  address     = "https://nomad.day2.sololab"
  skip_verify = true
  credential = {
    "secret_id" = {
      vault_kvv2 = {
        mount = "kvv2_nomad"
        name  = "token-management"
        key   = "token"
      }
    }
  }
}

policies = [
  {
    name        = "admin"
    description = "admin policy"
    rules       = <<-EOT
      namespace "*" {
        policy = "write"
        capabilities = [
          "alloc-exec",
          "alloc-lifecycle",
          "alloc-node-exec",
          "csi-list-volume",
          "csi-mount-volume",
          "csi-read-volume",
          "csi-register-plugin",
          "csi-write-volume",
          "dispatch-job",
          "list-jobs",
          "list-scaling-policies",
          "read-fs",
          "read-job",
          "read-logs",
          "read-scaling-policy",
          "scale-job",
          "sentinel-override",
          "submit-job"
        ]
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
      host_volume "hvol-*" {
        policy = "write"
      }

      plugin {
        policy = "read"
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
        vault_kvv2_path = "kvv2_nomad"
      }
    }
  },
  {
    name         = "admin"
    description  = "admin role"
    policy_names = ["admin"]
    # https://developer.hashicorp.com/nomad/commands/acl/binding-rule/create#examples
    auth_binding_selector = "\"app-nomad-admin\" in list.roles"
  },
  {
    name         = "node-write"
    description  = "Role of nomad node (token-node_write)"
    policy_names = ["node-write"]
    token = {
      store = {
        vault_kvv2_path = "kvv2_nomad"
      }
    }
  },
]
