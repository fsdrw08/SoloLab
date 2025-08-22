prov_vault = {
  schema          = "https"
  address         = "vault.day1.sololab:8200"
  token           = "95eba8ed-f6fc-958a-f490-c7fd0eda5e9e"
  skip_tls_verify = true
}

kvv2 = [
  {
    mount_path = "kvv2-certs"
  },
  {
    mount_path  = "kvv2-consul"
    description = "kvv2 secret backend for consul"
  },
  {
    mount_path  = "kvv2-minio"
    description = "kvv2 secret backend for minio"
  },
  {
    mount_path  = "kvv2-vault_token"
    description = "kvv2 secret backend for vault token"
  },
  {
    mount_path  = "kvv2-nomad"
    description = "kvv2 secret backend for nomad"
  },
]
