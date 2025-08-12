services {
  name = "gitea"
  id   = "redis"
  port = 6379

  checks = [
    {
      id       = "redis-tcp-check"
      name     = "redis-tcp-check"
      tcp      = "gitea-redis.day1.sololab:6379"
      interval = "300s"
      timeout  = "2s"
    }
  ]
}