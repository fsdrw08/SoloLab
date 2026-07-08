services {
  name = "redis"
  id   = "redis"
  port = 6379

  checks = [
    {
      id       = "redis-tcp-check"
      name     = "redis-tcp-check"
      tcp      = "127.0.0.1:6379"
      interval = "300s"
      timeout  = "2s"
      status   = "passing"
    }
  ]
  tags = [
    "day2"
  ]
}
