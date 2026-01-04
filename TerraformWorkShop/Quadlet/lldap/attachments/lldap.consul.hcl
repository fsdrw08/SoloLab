services {
  name = "lldap"
  id   = "lldap-server"
  port = 443

  checks = [
    {
      # https://developer.hashicorp.com/consul/docs/services/usage/checks#http-checks
      id              = "lldap-https-check"
      name            = "lldap-https-check"
      http            = "http://localhost:17170/health"
      tls_skip_verify = true
      interval        = "300s"
      timeout         = "2s"
      status          = "passing"
    }
  ]

  tags = [
    "metrics-exposing-blackbox",

    # "traefik.enable=true",
    # "traefik.tcp.routers.lldap-web.entrypoints=webSecure",
    # "traefik.tcp.routers.lldap-web.rule=HostSNI(`lldap.day1.sololab`)",
    # "traefik.tcp.routers.lldap-web.tls.passthrough=true",
    # "traefik.http.routers.lldap-web-redirect.entrypoints=web",
    # "traefik.http.routers.lldap-web-redirect.rule=Host(`lldap.day1.sololab`)",
    # "traefik.http.routers.lldap-web-redirect.middlewares=toHttps@file",
    # "traefik.http.routers.lldap-web.entrypoints=websecure",
    # "traefik.http.routers.lldap-web.rule=Host(`lldap.day1.sololab`)",
    # "traefik.http.routers.lldap-web.tls=true",
    # "traefik.http.services.lldap-web.loadbalancer.server.scheme=https",
  ]
  meta = {
    scheme            = "https"
    address           = "lldap.day0.sololab"
    health_check_path = "health"
  }
}