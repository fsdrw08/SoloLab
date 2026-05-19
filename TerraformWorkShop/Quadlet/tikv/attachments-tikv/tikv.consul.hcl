# https://developer.hashicorp.com/consul/docs/reference/service
services {
  name = "tikv"
  id   = "tikv"
  port = 443

  checks = [
    {
      # https://developer.hashicorp.com/consul/docs/services/usage/checks#http-checks
      id              = "tikv-https-check"
      name            = "tikv-https-check"
      http            = "http://localhost:20180/status"
      tls_skip_verify = true
      interval        = "300s"
      timeout         = "2s"
      status          = "passing"
    }
  ]

  tags = [
    "metrics-exposing-blackbox",
    "metrics-exposing-general",
  ]
  meta = {
    prom_blackbox_scheme            = "https"
    prom_blackbox_address           = "tikv.day1.sololab"
    prom_blackbox_health_check_path = "status"

    prom_target_scheme  = "https"
    prom_target_address = "tikv.day1.sololab"
    # https://tikv.org/docs/7.1/deploy/configure/tikv-command-line/#--status-addr
    prom_target_metrics_path = "metrics"
  }
}
