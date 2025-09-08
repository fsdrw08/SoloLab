services {
  name = "dufs"
  id   = "dufs-server"
  port = 5001

  checks = [
    {
      id              = "dufs-http-check"
      name            = "dufs-http-check"
      http            = "http://localhost:5001/__dufs__/health"
      tls_skip_verify = true
      interval        = "300s"
      timeout         = "2s"
      status          = "passing"
    }
  ]


}
