services {
  id   = "vault-web"
  name = "vault"
  port = 8200

  checks = [
    {
      # https://developer.hashicorp.com/consul/docs/services/usage/checks#http-checks
      id              = "vault-https-check"
      name            = "vault-https-check"
      http            = "https://vault.day0.sololab/v1/sys/health"
      tls_skip_verify = true
      interval        = "300s"
      timeout         = "2s"
    }
  ]

  tags = [
    "vault-exporter",
  ]
  meta = {
    scheme                    = "https"
    address                   = "vault.day0.sololab"
    health_check_path         = "v1/sys/health"
    metrics_path              = "v1/sys/metrics"
    metrics_path_param_format = "prometheus"
  }
}