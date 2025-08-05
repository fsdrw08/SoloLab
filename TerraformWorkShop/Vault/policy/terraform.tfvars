prov_vault = {
  address         = "https://vault.day1.sololab:8200"
  token           = "95eba8ed-f6fc-958a-f490-c7fd0eda5e9e"
  skip_tls_verify = true
}

policy_bindings = [
  {
    policy_name = "vault-admin"
    # ref: https://github.com/kencx/homelab/blob/1c451e1634f818e9d912bb054db47988cb083989/terraform/vault/policies/admin.hcl#L75
    policy_content = <<-EOT
      ## System Backend
      # Read system health check
      path "sys/health" {
        capabilities = ["read", "sudo"]
      }
      path "sys/audit" {
        capabilities = ["read", "create", "sudo"]
      }
      # Manage leases
      path "sys/leases/*" {
        capabilities = ["create", "read", "update", "delete", "list", "sudo"]
      }
      ## ACL Policies
      # Create, manage ACL policies
      path "sys/policies/acl/*" {
        capabilities = ["create", "read", "update", "delete", "list", "sudo"]
      }
      # List existing policies
      path "sys/policies/acl" {
        capabilities = ["list"]
      }
      # Deny changing own policy
      path "sys/policies/acl/admin" {
        capabilities = ["read"]
      }
      ## Auth Methods
      # Manage auth methods
      path "auth/*" {
        capabilities = ["create", "read", "update", "delete", "list", "sudo"]
      }
      # Create, update, delete auth methods
      path "sys/auth/*" {
        capabilities = ["create", "update", "delete", "sudo"]
      }
      # List auth methods
      path "sys/auth" {
        capabilities = ["read"]
      }
      ## IdentityEntity
      path "identity/entity/*" {
        capabilities = ["create", "update", "delete", "read"]
      }
      path "identity/entity/name" {
        capabilities = ["list"]
      }
      path "identity/entity/id" {
        capabilities = ["list"]
      }
      path "identity/entity-alias/*" {
        capabilities = ["create", "update", "delete", "read"]
      }
      path "identity/entity-alias/id" {
        capabilities = ["list"]
      }
      path "identity/oidc/*" {
        capabilities = ["create", "read", "update", "delete", "list", "sudo"]
      }
      ## KV Secrets Engine
      # manage kv secrets engine
      path "kvv2/*" {
        capabilities = ["create", "read", "update", "delete", "list", "sudo"]
      }
      # Manage secrets engine
      path "sys/mounts/*" {
        capabilities = ["create", "read", "update", "delete", "list", "sudo"]
      }
      # List secrets engine
      path "sys/mounts" {
        capabilities = ["read"]
      }
      ## PKI - Intermediate CA
      path "pki/config/urls" {
        capabilities = ["read"]
      }
      # Create, update roles
      path "pki_int/roles/*" {
        capabilities = ["create", "read", "update", "delete", "list", "sudo"]
      }
      # List roles
      path "pki_int/roles" {
        capabilities = ["list"]
      }
      # Issue certs
      path "pki_int/issue/*" {
        capabilities = ["create", "update"]
      }
      # Read certs
      path "pki_int/cert/*" {
        capabilities = ["read"]
      }
      # Revoke certs
      path "pki_int/revoke" {
        capabilities = ["create", "update", "read"]
      }
      # List certs
      path "pki_int/certs" {
        capabilities = ["list"]
      }
      # Tidy certs
      path "pki_int/tidy" {
        capabilities = ["create", "update", "read"]
      }
      path "pki_int/tidy-status" {
        capabilities = ["read"]
      }
      EOT
    group_binding = {
      policy_group    = "Policy-Vault-Admin"
      external_groups = ["app-vault-admin"]
    }
  },
  # https://github.com/doohee323/tz-k8s-vagrant/blob/9149105349fdd6bf045fbea598f1b01f17ba899b/tz-local/resource/vault/data/read-role.hcl#L4
  {
    policy_name    = "vault-user"
    policy_content = <<-EOT
      path "identity/group/*" {
        capabilities = ["list", "read"]
      }
      path "identity/entity/id" {
        capabilities = ["list"]
      }
      path "identity/entity/id/{{identity.entity.id}}" {
        capabilities = ["read"]
      }
      path "auth/*" {
        capabilities = ["list", "read"]
      }
      path "sys/*" {
        capabilities = ["list", "read"]
      }
      path "sys/policy" {
        capabilities = ["list", "read"]
      }
      EOT
    group_binding = {
      policy_group    = "Policy-Vault-User"
      external_groups = ["app-vault-user"]
    }
  },
  {
    policy_name    = "prometheus-metrics"
    policy_content = <<-EOT
      path "/sys/metrics" {
        capabilities = ["read"]
      }
      EOT
    # https://discuss.hashicorp.com/t/help-why-do-tokens-always-expire-at-32-days-even-when-renewed/50351/8
    token_binding = {
      display_name = "prometheus-metrics"
      no_parent    = true
    }
  }
]
