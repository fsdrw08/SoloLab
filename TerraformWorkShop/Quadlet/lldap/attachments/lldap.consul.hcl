services {
  name = "lldap"
  id   = "lldap-web"
  port = 17170

  checks = [
    {
      # https://developer.hashicorp.com/consul/docs/services/usage/checks#http-checks
      id              = "lldap-https-check"
      name            = "lldap-https-check"
      http            = "https://lldap.day0.sololab/login"
      tls_skip_verify = true
      interval        = "300s"
      timeout         = "2s"
    }
  ]

  # tags = [
  #   "traefik.enable=true",
  #   "traefik.tcp.routers.lldap-web.entrypoints=webSecure",
  #   "traefik.tcp.routers.lldap-web.rule=HostSNI(`lldap.day1.sololab`)",
  #   "traefik.tcp.routers.lldap-web.tls.passthrough=true",
  #   # "traefik.http.routers.lldap-web-redirect.entrypoints=web",
  #   # "traefik.http.routers.lldap-web-redirect.rule=Host(`lldap.day1.sololab`)",
  #   # "traefik.http.routers.lldap-web-redirect.middlewares=toHttps@file",
  #   # "traefik.http.routers.lldap-web.entrypoints=websecure",
  #   # "traefik.http.routers.lldap-web.rule=Host(`lldap.day1.sololab`)",
  #   # "traefik.http.routers.lldap-web.tls=true",
  #   # "traefik.http.services.lldap-web.loadbalancer.server.scheme=https",
  # ]
}