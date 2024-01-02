service {
  id      = "traefik"
  name    = "traefik"
  address = "traefik.service.consul"

  checks = [
    {
      id       = "traefik-tcp-check-443"
      name     = "traefik-tcp-check-443"
      tcp      = "192.168.255.2:443"
      interval = "20s"
      timeout  = "2s"
    }
  ]
}
