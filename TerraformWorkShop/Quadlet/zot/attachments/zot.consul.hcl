services {
  name = "zot-day0"
  id   = "zot-registry"
  port = 5000

  checks = [
    {
      # https://developer.hashicorp.com/consul/docs/services/usage/checks#http-checks
      id              = "zot-https-check"
      name            = "zot-https-check"
      http            = "https://localhost:5000/v2/"
      tls_skip_verify = true
      interval        = "300s"
      timeout         = "2s"
      status          = "passing"
    }
  ]

  # https://github.com/project-zot/zot/issues/2149
  # not able to scrape metric as http 401
  # tags = [
  #   "exporter",
  # ]

  meta = {
    scheme            = "https"
    address           = "zot.day0.sololab"
    health_check_path = "v2/"
    metrics_path      = "metrics"
  }
}
