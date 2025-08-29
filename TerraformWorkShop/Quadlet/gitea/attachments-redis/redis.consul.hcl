services {
  name = "gitea-redis"
  id   = "redis"
  port = 6379

  checks = [
    {
      id       = "redis-tcp-check"
      name     = "redis-tcp-check"
      tcp      = "localhost:6379"
      interval = "300s"
      timeout  = "2s"
    }
  ]
}