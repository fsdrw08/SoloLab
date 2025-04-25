prov_vault = {
  address         = "https://vault.day0.sololab:8200"
  token           = "95eba8ed-f6fc-958a-f490-c7fd0eda5e9e"
  skip_tls_verify = true
}

policy_bindings = [
  {
    policy_name     = "vault-admin"
    policy_content  = <<-EOT
      path "*" {
        capabilities = ["create", "read", "update", "patch", "delete", "list", "sudo"]
      }
      EOT
    policy_group    = "Policy-Vault-Admin"
    external_groups = ["app-vault-admin"]
  },
  # https://github.com/doohee323/tz-k8s-vagrant/blob/9149105349fdd6bf045fbea598f1b01f17ba899b/tz-local/resource/vault/data/read-role.hcl#L4
  {
    policy_name     = "vault-user"
    policy_content  = <<-EOT
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
    policy_group    = "Policy-Vault-User"
    external_groups = ["app-vault-user"]
  },
]
