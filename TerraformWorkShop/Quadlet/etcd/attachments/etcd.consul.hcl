services {
  name = "etcd"
  id   = "etcd-0"
  port = 443 # 2379

  checks = [
    {
      # https://developer.hashicorp.com/consul/docs/services/usage/checks#http-checks
      id              = "etcd-https-check"
      name            = "etcd-https-check"
      http            = "https://localhost:2379/health"
      tls_skip_verify = true
      interval        = "300s"
      timeout         = "2s"
      status          = "passing"
    }
  ]

  # https://github.com/project-etcd/etcd/issues/2149
  # not able to scrape metric as http 401
  tags = [
    "metrics-exposing-blackbox",
    "metrics-exposing-general",
  ]

  meta = {
    prom_blackbox_scheme            = "https"
    prom_blackbox_address           = "etcd-0.day0.sololab"
    prom_blackbox_health_check_path = "health"

    prom_target_scheme       = "https"
    prom_target_address      = "etcd-0.day0.sololab"
    prom_target_metrics_path = "metrics"
  }
}
