prov_vault = {
  address         = "https://vault.day1.sololab:8200"
  token           = "95eba8ed-f6fc-958a-f490-c7fd0eda5e9e"
  skip_tls_verify = true
}

policy_bindings = [
  {
    policy_name     = "admin"
    policy_content  = <<-EOT
      path "*" {
        capabilities = ["create", "read", "update", "patch", "delete", "list", "sudo"]
      }
      EOT
    policy_group    = "Policy-Vault-Admin"
    external_groups = ["App-Vault-Admin"]
  },
  {
    policy_name     = "consul-auto_config"
    policy_content  = <<-EOT
      path "identity/oidc/token/consul_auto_config" {
        capabilities = ["read"]
      }
      path "identity/entity/id" {
        capabilities = ["list"]
      }
      path "identity/entity/id/{{identity.entity.id}}" {
        capabilities = ["read", "update"]
      }
      EOT
    policy_group    = "Policy-Consul-auto_config"
    external_groups = ["App-Consul-Auto_Config"]
  },
]
