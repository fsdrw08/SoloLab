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

  tags = [
    "metrics-exposing-blackbox",
    # https://github.com/project-zot/zot/issues/2149
    # not able to scrape metric as http 401
    # "metrics-exposing-general",
  ]

  meta = {
    prom_blackbox_scheme            = "https"
    prom_blackbox_address           = "zot.vyos.sololab"
    prom_blackbox_health_check_path = "v2/"

    # prom_target_scheme       = "https"
    # prom_target_address      = "zot.vyos.sololab"
    # prom_target_metrics_path = "metrics"
    # health_check_path        = "v2/"
  }
}
