prov_vault = {
  address         = "https://vault.day1.sololab"
  skip_tls_verify = true
}

# https://github.com/hashicorp-modules/terraform-vault-nomad-setup/blob/main/main.tf
jwt_auth = {
  path        = "jwt-nomad"
  description = "JWT auth backend for Nomad"
  jwks_ca_pem = {
    vault_kvv2 = {
      mount = "kvv2_certs"
      name  = "sololab_root"
      key   = "ca"
    }
  }
  jwks_url = "https://nomad.day2.sololab/.well-known/jwks.json"
  jwt_supported_algs = [
    "RS256",
    "EdDSA"
  ]
  default_role = "nomad-workload"
  roles = [
    {
      role_name = "nomad-workload"
      role_type = "jwt"
      bound_audiences = [
        "vault.io"
      ]
      user_claim              = "/nomad_job_id"
      user_claim_json_pointer = true
      claim_mappings = {
        nomad_namespace = "nomad_namespace"
        nomad_job_id    = "nomad_job_id"
        nomad_group     = "nomad_group"
        nomad_task      = "nomad_task"
      }
      token_type = "service"
      token_policies = [
        "nomad-workload-identity"
      ]
      token_period           = 3600
      token_explicit_max_ttl = 0
    },
    {
      role_name = "vault-admin"
      role_type = "jwt"
      bound_audiences = [
        "vault.io"
      ]
      user_claim              = "/nomad_job_id"
      user_claim_json_pointer = true
      claim_mappings = {
        nomad_namespace = "nomad_namespace"
        nomad_job_id    = "nomad_job_id"
        nomad_group     = "nomad_group"
        nomad_task      = "nomad_task"
      }
      token_type = "service"
      token_policies = [
        "vault-admin"
      ]
      token_period           = 3600
      token_explicit_max_ttl = 0
    }
  ]
}
