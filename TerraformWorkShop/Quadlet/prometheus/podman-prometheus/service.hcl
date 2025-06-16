services {
  id   = "prometheus"
  name = "prometheus"
  port = 9090

  checks = [
    {
      # https://developer.hashicorp.com/consul/docs/services/usage/checks#http-checks
      id              = "prometheus-https-check"
      name            = "prometheus-https-check"
      http            = "https://prometheus.day1.sololab/-/healthy"
      tls_skip_verify = true
      interval        = "300s"
      timeout         = "2s"
    }
  ]
  meta = {
    scheme = "https"
    address = "prometheus.day1.sololab"
  }
}

services {
  id   = "prometheus-blackbox-exporter"
  name = "prometheus-blackbox-exporter"
  port = 9115

  checks = [
    {
      # https://developer.hashicorp.com/consul/docs/services/usage/checks#http-checks
      id              = "prometheus-blackbox-exporter-https-check"
      name            = "prometheus-blackbox-exporter-https-check"
      http            = "https://prometheus-blackbox-exporter.day1.sololab/-/healthy"
      tls_skip_verify = true
      interval        = "300s"
      timeout         = "2s"
    }
  ]

  meta = {
    scheme = "https"
    address = "prometheus-blackbox-exporter.day1.sololab"
  }
}