services {
  name = "zot-vyos"
  id   = "zot-registry"
  port = 443

  checks = [
    {
      # https://developer.hashicorp.com/consul/docs/services/usage/checks#http-checks
      id              = "zot-http-check"
      name            = "zot-http-check"
      http            = "https://zot.vyos.sololab/v2/"
      tls_skip_verify = true
      interval        = "300s"
      timeout         = "2s"
      status          = "passing"
    }
  ]

  # https://github.com/project-zot/zot/issues/2149
  # not able to scrape metric as http 401
  # tags = [
  #   "metrics-exposing-blackbox",
  #   "metrics-exposing-general",
  # ]

  meta = {
    exporter_scheme       = "https"
    exporter_address      = "zot.vyos.sololab"
    health_check_path     = "v2/"
    exporter_metrics_path = "metrics"
  }
}
