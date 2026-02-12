services {
  name = "cockpit-vyos"
  id   = "cockpit-web"
  port = 443 # 9090

  checks = [
    # https://developer.hashicorp.com/consul/docs/services/usage/checks#http-checks
    {
      id   = "cockpit-https-check"
      name = "cockpit-https-check"
      # https://cockpit-project.org/guide/latest/https.html
      http            = "https://172.16.80.10:9090/ping"
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
    prom_blackbox_address           = "cockpit.vyos.sololab"
    prom_blackbox_health_check_path = "ping"

  }
}