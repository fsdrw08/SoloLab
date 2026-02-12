services {
  name = "dufs"
  id   = "dufs-server"
  port = 443 # 5001

  checks = [
    {
      id              = "dufs-http-check"
      name            = "dufs-http-check"
      http            = "http://localhost:5001/__dufs__/health"
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
    prom_blackbox_address           = "dufs.day0.sololab"
    prom_blackbox_health_check_path = "__dufs__/health"
  }
}
