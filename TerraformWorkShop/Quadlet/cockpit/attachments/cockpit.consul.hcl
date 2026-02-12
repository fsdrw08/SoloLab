services {
  name = "cockpit"
  id   = "cockpit-web"
  port = 443

  checks = [
    # https://developer.hashicorp.com/consul/docs/services/usage/checks#http-checks
    {
      id   = "cockpit-https-check"
      name = "cockpit-https-check"
      # https://cockpit-project.org/guide/latest/https.html
      http            = "https://localhost:9090/ping"
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
    prom_blackbox_address           = "cockpit.day0.sololab"
    prom_blackbox_health_check_path = "ping"
  }
}