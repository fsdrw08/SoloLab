services {
  name = "keycloak-pg"
  id   = "keycloak-pg-postgresql"
  port = 5432

  # https://developer.hashicorp.com/consul/docs/services/usage/checks
  checks = [
    {
      id       = "postgresql-tcp-check"
      name     = "postgresql-tcp-check"
      tcp      = "localhost:5432"
      interval = "300s"
      timeout  = "2s"
      status   = "passing"
    }
  ]
}
