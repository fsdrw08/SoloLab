# https://developer.hashicorp.com/consul/docs/reference/service
services {
  name = "minio-vyos"
  id   = "minio-api"
  port = 443

  checks = [
    {
      # https://developer.hashicorp.com/consul/docs/services/usage/checks#http-checks
      id              = "minio-api-https-check"
      name            = "minio-api-https-check"
      http            = "https://localhost:9000/minio/health/live"
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
    prom_target_scheme       = "https"
    prom_target_address      = "minio-api.vyos.sololab"
    prom_target_metrics_path = "minio/v2/metrics/cluster"

    prom_blackbox_scheme            = "https"
    prom_blackbox_address           = "minio-api.vyos.sololab"
    prom_blackbox_health_check_path = "minio/health/live"
  }
}

services {
  name = "minio-vyos"
  id   = "minio-console"
  port = 443

  checks = [
    {
      # https://developer.hashicorp.com/consul/docs/services/usage/checks#http-checks
      id              = "minio-console-https-check"
      name            = "minio-console-https-check"
      http            = "https://localhost:9001/"
      tls_skip_verify = true
      interval        = "300s"
      timeout         = "2s"
      status          = "passing"
    }
  ]
}