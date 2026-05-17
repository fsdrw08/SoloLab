# https://developer.hashicorp.com/consul/docs/reference/service
services {
  name = "pd"
  id   = "pd"
  port = 443

  checks = [
    {
      # https://developer.hashicorp.com/consul/docs/services/usage/checks#http-checks
      id              = "pd-https-check"
      name            = "pd-https-check"
      http            = "http://localhost:12379/pd/api/v1/members"
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
    prom_blackbox_address           = "pd.day1.sololab"
    prom_blackbox_health_check_path = "pd/api/v1/members"

    prom_target_scheme       = "https"
    prom_target_address      = "pd.day1.sololab"
    prom_target_metrics_path = "metrics"
  }
}
