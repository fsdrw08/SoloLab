services {
  name = "sftpgo"
  id   = "sftpgo-server"
  port = 443 # 5001

  checks = [
    {
      id              = "sftpgo-http-check"
      name            = "sftpgo-http-check"
      http            = "http://localhost:8081/healthz"
      tls_skip_verify = true
      interval        = "300s"
      timeout         = "2s"
      status          = "passing"
    }
  ]

}
