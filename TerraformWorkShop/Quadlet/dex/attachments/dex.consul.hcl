services {
  name = "dex"
  id   = "dex-server"
  port = 5001

  checks = [
    {
      id              = "dex-http-check"
      name            = "dex-http-check"
      http            = "http://localhost:5558/healthz/live"
      tls_skip_verify = true
      interval        = "300s"
      timeout         = "2s"
      status          = "passing"
    }
  ]


}
