service {
  id = "whoami"
  name = "whoami"
  address = "whoami.service.consul"

  tags = [
    "traefik.enable=true",
    "traefik.http.routers.whoami.entryPoints: websecure",
    "traefik.http.routers.whoami.rule=Host(`whoamii.infra.sololab`)",
    "traefik.http.routers.whoami.tls.certresolver=internal",
    // https://doc.traefik.io/traefik/routing/services/#pass-host-header
    // https://community.traefik.io/t/how-do-i-pass-a-host-header-to-my-loadbalancer-backend/4168
    "traefik.http.services.whoami.loadbalancer.passhostheader=false",
    "traefik.http.services.whoami.loadbalancer.server.scheme=https",
    "traefik.http.services.whoami.loadbalancer.server.port=443",
  ]

  checks = [
    {
      id = "whoami-tcp-check-443"
      name = "whoami-tcp-check-443"
      tcp = "whoami.service.consul:443"
      interval = "120s"
      timeout = "2s"
    }
  ]
}