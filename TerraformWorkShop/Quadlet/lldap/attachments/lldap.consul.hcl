services {
  name = "lldap"
  id   = "lldap-server"
  port = 443

  checks = [
    {
      # https://developer.hashicorp.com/consul/docs/services/usage/checks#http-checks
      id              = "lldap-https-check"
      name            = "lldap-https-check"
      http            = "http://localhost:17170/health"
      tls_skip_verify = true
      interval        = "300s"
      timeout         = "2s"
      status          = "passing"
    }
  ]

  tags = [
    "metrics-exposing-blackbox",
  ]
  meta = {
    prom_blackbox_scheme            = "https"
    prom_blackbox_address           = "lldap.day0.sololab"
    prom_blackbox_health_check_path = "health"
  }
}