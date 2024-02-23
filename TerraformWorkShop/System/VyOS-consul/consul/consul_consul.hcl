// https://developer.hashicorp.com/consul/docs/services/configuration/services-configuration-reference
services {
  id      = "consul-internal-http"
  name    = "consul-internal"
  address = "127.0.0.1"
  port    = 8500

  checks = [
    {
      id       = "consul-tcp-check-8500"
      name     = "consul-tcp-check-8500"
      tcp      = "127.0.0.1:8500"
      interval = "20s"
      timeout  = "2s"
    }
  ]

   tags = [
    "traefik.enable=true",
    "traefik.http.routers.consul-http.entrypoints=web",
    "traefik.http.routers.consul-http.rule=Host(`consul.service.consul`)",
    "traefik.http.services.consul-http.loadbalancer.server.scheme=http",
  ]
}

services {
  id      = "consul-internal-https"
  name    = "consul-internal"
  address = "127.0.0.1"
  port    = 8501

  weights = {
    passing = 1
  }

  checks = [
    {
      id       = "consul-tcp-check-8501"
      name     = "consul-tcp-check-8501"
      tcp      = "127.0.0.1:8501"
      interval = "20s"
      timeout  = "2s"
    }
  ]

   tags = [
    "traefik.enable=true",
    "traefik.tcp.routers.consul-https.entrypoints=websecure",
    "traefik.tcp.routers.consul-https.rule=HostSNI(`consul.service.consul`)",
    "traefik.tcp.routers.consul-https.tls.passthrough=true",
  ]
}

services {
  id      = "consul-external"
  name    = "consul"
}
