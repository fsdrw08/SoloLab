services {
  id      = "ci-traefik-80"
  name    = "ci-traefik"
  port    = 80

  checks = [
    {
      id       = "traefik-tcp-check-80"
      name     = "traefik-tcp-check-80"
      tcp      = "192.168.255.10:80"
      interval = "20s"
      timeout  = "2s"
    }
  ]
}

services {
  id      = "ci-traefik-443"
  name    = "ci-traefik"
  port    = 443

  checks = [
    {
      id       = "traefik-tcp-check-443"
      name     = "traefik-tcp-check-443"
      tcp      = "192.168.255.10:443"
      interval = "20s"
      timeout  = "2s"
    }
  ]
}
