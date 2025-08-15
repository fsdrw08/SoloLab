prov_nomad = {
  address     = "https://nomad.day1.sololab:4646"
  skip_verify = true
}

prov_vault = {
  address         = "https://vault.day1.sololab:8200"
  token           = "95eba8ed-f6fc-958a-f490-c7fd0eda5e9e"
  skip_tls_verify = true
}

policies = [
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
    name         = "node-write"
    description  = "Role of nomad node"
    policy_names = ["node-write"]
    token = {
      store = {
        vault_kvv2_path = "kvv2/nomad"
      }
    }
  },
]
