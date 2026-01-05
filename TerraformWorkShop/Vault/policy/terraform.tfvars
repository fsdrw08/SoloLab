prov_vault = {
  address         = "https://vault.day0.sololab"
  token           = "95eba8ed-f6fc-958a-f490-c7fd0eda5e9e"
  skip_tls_verify = true
}

vault_secret_backend = "kvv2_vault"

policy_bindings = [
  # vault-admin
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
      # manage pki secrets engine, the path is related to path name
      path "pki*" {
        capabilities = ["create", "read", "update", "delete", "list", "sudo"]
      }
      # manage kv secrets engine, the path is related to path name
      path "kvv2*" {
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
      path "pki_int/config/urls" {
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
  # vault-user
  {
    policy_name    = "vault-user"
    policy_content = <<-EOT
      path "auth/*" {
        capabilities = ["list", "read"]
      }
      path "identity/group/*" {
        capabilities = ["list", "read"]
      }
      path "identity/entity/id" {
        capabilities = ["list"]
      }
      path "identity/entity/id/{{identity.entity.id}}" {
        capabilities = ["read"]
      }
      path "kvv2_certs/data/*" {
        capabilities = ["read"]
      }

      path "kvv2_certs/data/" {
        capabilities = ["read"]
      }

      path "kvv2_certs/metadata/*" {
        capabilities = ["list"]
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
      renewable    = true
    }
  },
  # https://developer.hashicorp.com/consul/tutorials/operate-consul/vault-pki-consul-connect-ca
  # https://developer.hashicorp.com/consul/docs/secure-mesh/certificate/vault
  {
    policy_name    = "consul-ca"
    policy_content = <<-EOT
      # Allow Consul to read both PKI mounts and to manage the intermediate PKI mount configuration:
      path "/sys/mounts/pki_consul_root" {
        capabilities = [ "read" ]
      }
      path "/sys/mounts/pki_consul_int" {
        capabilities = [ "read" ]
      }
      path "/sys/mounts/pki_consul_int/tune" {
        capabilities = [ "update" ]
      }
      
      # Allow Consul read-only access to the root PKI engine, to automatically rotate intermediate CAs as needed, and full use of the intermediate PKI engine:
      path "/pki_consul_root/" {
        capabilities = [ "read" ]
      }
      path "/pki_consul_root/root/sign-intermediate" {
        capabilities = [ "update" ]
      }
      path "/pki_consul_int/*" {
        capabilities = [ "create", "read", "update", "delete", "list" ]
      }
      
      # Allow Consul to renew its Vault token if the token is renewable. 
      # The rule enables the token to be renewed whether it is provided directly in the CA provider configuration or presented in an auth method.
      path "auth/token/renew-self" {
        capabilities = [ "update" ]
      }
      path "auth/token/lookup-self" {
        capabilities = [ "read" ]
      }
    EOT
    token_binding = {
      display_name = "consul-ca"
      no_parent    = true
      renewable    = true
    }
  },
  {
    policy_name    = "cert-read"
    policy_content = <<-EOT
      path "kvv2_certs/data/*" {
        capabilities = ["read"]
      }

      path "kvv2_certs/data/" {
        capabilities = ["read"]
      }

      path "kvv2_certs/metadata/*" {
        capabilities = ["list"]
      }
    EOT
  },
  {
    policy_name    = "pgsql-read"
    policy_content = <<-EOT
      path "kvv2_pgsql/data/*" {
        capabilities = ["read"]
      }

      path "kvv2_pgsql/data/" {
        capabilities = ["read"]
      }

      path "kvv2_pgsql/metadata/*" {
        capabilities = ["list"]
      }
    EOT
  }
]
