# https://developer.hashicorp.com/consul/docs/reference/service
services {
  name = "shellcrash"
  id   = "shellcrash-vyos"
  port = 443

  checks = [
    {
      # https://developer.hashicorp.com/consul/docs/services/usage/checks#http-checks
      id              = "shellcrash-https-check"
      name            = "shellcrash-https-check"
      http            = "https://localhost:9999/"
      tls_skip_verify = true
      interval        = "300s"
      timeout         = "2s"
      status          = "passing"
    }
  ]
}
