services {
  id      = "traefik-80"
  name    = "traefik"
  port    = 80

  checks = [
    {
      id       = "traefik-tcp-check-80"
      name     = "traefik-tcp-check-80"
      tcp      = "192.168.255.2:80"
      interval = "20s"
      timeout  = "2s"
    },
    {
      id       = "traefik-health-check-8080"
      name     = "traefik-health-check-8080"
      http     = "http://192.168.255.2:8080/ping"
      method   = "GET"
      interval = "20s"
      timeout  = "2s"
    }
  ]
}

services {
  id      = "traefik-443"
  name    = "traefik"
  port    = 443

  checks = [
    {
      id       = "traefik-tcp-check-443"
      name     = "traefik-tcp-check-443"
      tcp      = "192.168.255.2:443"
      interval = "20s"
      timeout  = "2s"
    },
    {
      id       = "traefik-health-check-8080"
      name     = "traefik-health-check-8080"
      http     = "http://192.168.255.2:8080/ping"
      method   = "GET"
      interval = "20s"
      timeout  = "2s"
    }
  ]
}
