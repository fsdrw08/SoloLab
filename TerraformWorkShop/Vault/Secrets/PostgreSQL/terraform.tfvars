prov_vault = {
  address         = "https://vault.day1.sololab"
  skip_tls_verify = true
}

mount = "kvv2_pgsql"

databases = [
  {
    name           = "postgres_exporter"
    user_name      = "postgres_exporter"
    secret_version = 1
  },
  {
    name           = "test"
    user_name      = "test"
    secret_version = 1
  },
  {
    name           = "gitea"
    user_name      = "gitea"
    secret_version = 1
  },
  {
    name           = "otf"
    user_name      = "otf"
    secret_version = 1
  },
  {
    name           = "nexus"
    user_name      = "nexus"
    secret_version = 1
  },
]
