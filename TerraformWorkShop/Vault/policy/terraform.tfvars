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
]
