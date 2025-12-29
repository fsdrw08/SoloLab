prov_consul = {
  scheme         = "https"
  address        = "consul.day1.sololab:8501"
  datacenter     = "dc1"
  token          = "e95b599e-166e-7d80-08ad-aee76e7ddf19"
  insecure_https = true
}

nodes = [{
  name    = "Day0-FCOS"
  address = "192.168.255.10"
}]

services = [{
  name = "prometheus-podman-exporter-day0"
  node = "Day0-FCOS"
  port = 443 # 9882
  check = [{
    check_id        = "prometheus-podman-exporter-http-check"
    name            = "prometheus-podman-exporter-http-check"
    http            = "https://prometheus-podman-exporter.day0.sololab/"
    interval        = "300s"
    timeout         = "2s"
    tls_skip_verify = true
  }]
  tags = ["blackbox-exporter",
  "metrics-exposing"]
  meta = {
    scheme            = "https"
    address           = "prometheus-podman-exporter.day0.sololab"
    health_check_path = "metrics"
    metrics_path      = "metrics"
  }
}]
