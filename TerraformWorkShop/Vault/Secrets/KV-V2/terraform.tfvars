prov_vault = {
  schema          = "https"
  address         = "vault.day0.sololab"
  token           = "95eba8ed-f6fc-958a-f490-c7fd0eda5e9e"
  skip_tls_verify = true
}

kvv2 = [
  {
    mount_path = "kvv2_certs"
  },
  {
    mount_path  = "kvv2_consul"
    description = "kvv2 secret backend for consul"
  },
  {
    mount_path  = "kvv2_minio"
    description = "kvv2 secret backend for minio"
  },
  {
    mount_path  = "kvv2_vault"
    description = "kvv2 secret backend for vault"
  },
  {
    mount_path  = "kvv2_nomad"
    description = "kvv2 secret backend for nomad"
  },
  {
    mount_path  = "kvv2_pgsql"
    description = "kvv2 secret backend for pgsql"
  },
]
