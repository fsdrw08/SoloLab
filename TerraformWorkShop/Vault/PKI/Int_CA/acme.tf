# enable the acme configuration.
# https://www.infralovers.com/blog/2023-10-16-hashicorp-vault-acme-terraform-configuration/#:~:text=apply%20the%20secrets,1
resource "vault_generic_endpoint" "config_acme" {
  path                 = "${vault_mount.pki.path}/config/acme"
  ignore_absent_fields = true
  disable_delete       = true
  write_fields         = ["enabled"]
  data_json            = <<EOT
{
  "enabled": "true"
}
EOT
}


# apply the secrets engine tuning parameter
# ref: https://developer.hashicorp.com/vault/api-docs/secret/pki#acme-required-headers
resource "vault_generic_endpoint" "acme_headers" {
  path                 = "sys/mounts/${vault_mount.pki.path}/tune"
  ignore_absent_fields = true
  disable_delete       = true
  write_fields         = ["passthrough_request_headers", "allowed_response_headers", "audit_non_hmac_request_keys", "audit_non_hmac_response_keys"]
  data_json            = <<EOT
{
  "passthrough_request_headers": [
    "If-Modified-Since"
  ],
  "allowed_response_headers": [
    "Last-Modified", 
    "Location", 
    "Replay-Nonce", 
    "Link"
  ]
}
EOT
}
