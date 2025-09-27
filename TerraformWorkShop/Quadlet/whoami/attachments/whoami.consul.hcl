services {
  id   = "whoami"
  name = "whoami"
  port = 443 # 8081

  checks = [
    {
      # https://developer.hashicorp.com/consul/docs/services/usage/checks#http-checks
      id              = "whoami-http-check"
      name            = "whoami-http-check"
      http            = "http://localhost:8081/"
      tls_skip_verify = true
      interval        = "300s"
      timeout         = "2s"
      status          = "passing"
    }
  ]

}
