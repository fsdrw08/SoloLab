# https://github.com/jbaikge/homelab-nomad/blob/ce67445a95aa7dd5c2e5d72b11e06b078e44e67c/nomad/traefik.tf#L2
resource "nomad_job" "job" {
  jobspec = file("${path.module}/attachments/exporters.nomad.hcl")

  hcl2 {
    allow_fs = true
    vars = {
      # grafana_config = file("${path.module}/attachments/grafana.ini")
      grafana_config = templatefile("${path.module}/attachments/grafana.ini", {
        client_id     = data.vault_identity_oidc_client_creds.creds.client_id
        client_secret = data.vault_identity_oidc_client_creds.creds.client_secret
        auth_url      = "${data.vault_identity_oidc_openid_config.config.authorization_endpoint}?with=ldap"
        api_url       = data.vault_identity_oidc_openid_config.config.userinfo_endpoint
        token_url     = data.vault_identity_oidc_openid_config.config.token_endpoint
      })
    }
  }

  purge_on_destroy = true
}

