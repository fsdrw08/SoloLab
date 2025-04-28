prov_remote = {
  host     = "192.168.255.20"
  port     = 22
  user     = "podmgr"
  password = "podmgr"
}

podman_quadlet = {
  service = {
    name   = "traefik-container"
    status = "start"
  }
  files = [
    {
      template = "./podman-traefik/traefik-container.container"
      vars = {
        Description   = "Traefik Proxy"
        Documentation = "https://docs.traefik.io"
        yaml          = "traefik-aio.yaml"
        PodmanArgs    = "--tls-verify=false"
        Restart       = "on-failure"
      }
      dir = "/home/podmgr/.config/containers/systemd"
    },
    {
      template = "./podman-traefik/traefik-container.volume"
      vars = {
        VolumeName = "traefik-pvc"
      }
      dir = "/home/podmgr/.config/containers/systemd"
    }
  ]
}

prov_pdns = {
  api_key    = "powerdns"
  server_url = "http://pdns-auth.day0.sololab:8081"
}

dns_records = [
  {
    zone = "day1.sololab."
    name = "traefik.day1.sololab."
    type = "A"
    ttl  = 86400
    records = [
      "192.168.255.20"
    ]
  },
]
