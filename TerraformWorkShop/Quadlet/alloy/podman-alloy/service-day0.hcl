services {
  name = "alloy"
  id   = "alloy-day0"
  port = 12345

  checks = [
    {
      # https://developer.hashicorp.com/consul/docs/services/usage/checks#http-checks
      id              = "alloy-https-check"
      name            = "alloy-https-check"
      http            = "https://alloy.day0.sololab/"
      tls_skip_verify = true
      interval        = "300s"
      timeout         = "2s"
    }
  ]
}
services {
  name = "prometheus-podman-exporter"
  id   = "prometheus-podman-exporter-day0"
  port = 9882

  checks = [
    {
      # https://developer.hashicorp.com/consul/docs/services/usage/checks#http-checks
      id              = "prometheus-podman-exporter-http-check"
      name            = "prometheus-podman-exporter-http-check"
      http            = "http://prometheus-podman-exporter.day0.sololab/"
      interval        = "300s"
      timeout         = "2s"
    }
  ]
  tags = [
    "scrapable",
  ]
}