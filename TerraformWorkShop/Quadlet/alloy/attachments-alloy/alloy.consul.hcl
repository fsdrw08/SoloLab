services {
  name = "alloy"
  id   = "alloy-day1"
  port = 12345

  checks = [
    {
      # https://developer.hashicorp.com/consul/docs/services/usage/checks#http-checks
      id              = "alloy-https-check"
      name            = "alloy-https-check"
      http            = "https://alloy.day1.sololab/"
      tls_skip_verify = true
      interval        = "300s"
      timeout         = "2s"
    }
  ]
}
