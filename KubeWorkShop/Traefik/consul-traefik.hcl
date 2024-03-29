service {
  id = "dev-traefik"
  name = "dev-traefik"
  address = "dev-traefik.service.consul"

  tags = [
    "traefik.enable=true",
    "traefik.http.routers.dev-traefik.entryPoints: websecure",
    "traefik.http.routers.dev-traefik.rule=Host(`dev-traefik.infra.sololab`)",
    "traefik.http.routers.dev-traefik.tls.certresolver=internal",
    "traefik.http.services.dev-traefik.loadbalancer.passhostheader=false",
    "traefik.http.services.dev-traefik.loadbalancer.server.scheme=https",
    "traefik.http.services.dev-traefik.loadbalancer.server.port=443"
  ]

  checks = [
    {
      id = "dev-traefik-tcp-check-443"
      name = "dev-traefik-tcp-check-443"
      tcp = "localhost:443"
      interval = "120s"
      timeout = "2s"
    }
  ]
}