services {
  name = "sftpgo"
  id   = "sftpgo-server"
  port = 443 # 2080

  checks = [
    {
      id              = "sftpgo-http-check"
      name            = "sftpgo-http-check"
      http            = "http://localhost:2080/healthz"
      tls_skip_verify = true
      interval        = "300s"
      timeout         = "2s"
      status          = "passing"
    }
  ]

}
