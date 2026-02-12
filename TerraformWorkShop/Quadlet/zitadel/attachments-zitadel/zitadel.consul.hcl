services {
  name = "zot"
  id   = "zot-registry"
  port = 5000

  checks = [
    {
      # https://developer.hashicorp.com/consul/docs/services/usage/checks#http-checks
      id   = "zot-http-check"
      name = "zot-http-check"
      http = "http://localhost:5000/v2/"
      # tls_skip_verify = true
      interval = "300s"
      timeout  = "2s"
      status   = "passing"
    }
  ]

  # https://github.com/project-zot/zot/issues/2149
  # not able to scrape metric as http 401
  # tags = [
  #   "blackbox-exporter",
  "metrics-exposing",
  # ]

  meta = {
    prom_target_scheme       = "https"
    prom_target_address      = "zot.day0.sololab"
    health_check_path        = "v2/"
    prom_target_metrics_path = "metrics"
  }
}
