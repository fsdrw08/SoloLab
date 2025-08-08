services {
  id   = "redis"
  name = "redis-insight"
  port = 5540

  checks = [
    {
      id              = "redis-insight-http-check"
      name            = "redis-insight-http-check"
      http            = "https://redis-insight.day1.sololab//api/health"
      tls_skip_verify = true
      interval        = "300s"
      timeout         = "2s"
    }
  ]


}
