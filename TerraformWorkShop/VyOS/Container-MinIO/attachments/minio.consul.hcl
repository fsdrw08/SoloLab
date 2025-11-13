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
    "exporter",
  ]
  meta = {
    scheme            = "https"
    address           = "minio-api.vyos.sololab"
    health_check_path = "minio/health/live"
    metrics_path      = "minio/v2/metrics/cluster"
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