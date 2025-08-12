services {
  id   = "zot-web"
  name = "zot"
  port = 5000

  checks = [
    {
      # https://developer.hashicorp.com/consul/docs/services/usage/checks#http-checks
      id              = "zot-https-check"
      name            = "zot-https-check"
      http            = "https://zot.day0.sololab/v2/"
      tls_skip_verify = true
      interval        = "300s"
      timeout         = "2s"
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
