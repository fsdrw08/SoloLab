services {
  id   = "minio-api"
  name = "minio"
  port = 9000

  checks = [
    {
      # https://developer.hashicorp.com/consul/docs/services/usage/checks#http-checks
      id              = "minio-api-https-check"
      name            = "minio-api-https-check"
      http            = "https://minio-api.day1.sololab/minio/health/live"
      tls_skip_verify = true
      interval        = "300s"
      timeout         = "2s"
    }
  ]

  tags = [
    "exporter",
  ]
  meta = {
    scheme            = "https"
    address           = "minio-api.day1.sololab"
    health_check_path = "minio/health/live"
    metrics_path      = "minio/v2/metrics/cluster"
  }
}