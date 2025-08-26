prov_vault = {
  address         = "https://vault.day1.sololab"
  token           = "95eba8ed-f6fc-958a-f490-c7fd0eda5e9e"
  skip_tls_verify = true
}

jwt_auth_path  = "jwt-nomad"
nomad_jwks_url = "https://nomad.day1.sololab/.well-known/jwks.json"
policy_names = [
  "cert-read",
]
