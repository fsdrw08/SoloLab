services {
  id   = "dufs-web"
  name = "dufs"
  port = 5001

  checks = [
    {
      id              = "dufs-http-check"
      name            = "dufs-http-check"
      http            = "http://dufs.day0.sololab/__dufs__/health"
      tls_skip_verify = true
      interval        = "300s"
      timeout         = "2s"
    }
  ]


}
