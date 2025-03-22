services {
  id      = "powerdns-web"
  name    = "powerdns"
  port    = 8080

  checks = [
    {
      id       = "powerdns-http-check-8081"
      name     = "powerdns-http-check-8081"
      http      = "http://192.168.255.10:8080/api/v1/servers/localhost/statistics?statistic=uptime"
      interval = "300s"
      timeout  = "2s"
    }
  ]

  # tags = [
  #   "traefik.enable=true",
  #   "traefik.tcp.routers.nomad-web.entrypoints=webSecure",
  #   "traefik.tcp.routers.nomad-web.rule=HostSNI(`nomad.day1.sololab`)",
  #   "traefik.tcp.routers.nomad-web.tls.passthrough=true",
  #   # "traefik.http.routers.nomad-web-redirect.entrypoints=web",
  #   # "traefik.http.routers.nomad-web-redirect.rule=Host(`nomad.day1.sololab`)",
  #   # "traefik.http.routers.nomad-web-redirect.middlewares=toHttps@file",
  #   # "traefik.http.routers.nomad-web.entrypoints=websecure",
  #   # "traefik.http.routers.nomad-web.rule=Host(`nomad.day1.sololab`)",
  #   # "traefik.http.routers.nomad-web.tls=true",
  #   # "traefik.http.services.nomad-web.loadbalancer.server.scheme=https",
  # ]
}
