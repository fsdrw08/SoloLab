services {
  id   = "consul-web"
  name = "consul"
  port = 8501

  checks = [
    {
      id              = "consul-https-check"
      name            = "consul-https-check"
      http            = "https://consul.day0.sololab/v1/status/leader"
      tls_skip_verify = true
      interval        = "300s"
      timeout         = "2s"
    }
  ]

  tags = [
    "exporter",
  ]
  meta = {
    scheme  = "https"
    address = "consul.day0.sololab"
    # https://developer.hashicorp.com/consul/docs/reference/agent/configuration-file/telemetry#telemetry-prometheus_retention_time
    metrics_path              = "/v1/agent/metrics"
    metrics_path_param_format = "prometheus"
  }
}