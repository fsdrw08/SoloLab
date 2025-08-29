services {
  name = "redis-insight"
  id   = "redis-insight"
  port = 5540

  checks = [
    {
      id              = "redis-insight-http-check"
      name            = "redis-insight-http-check"
      http            = "https://localhost:5540/api/health"
      tls_skip_verify = true
      interval        = "300s"
      timeout         = "2s"
    }
  ]


}
