prov_vault = {
  address         = "https://vault.day0.sololab:8200"
  token           = "95eba8ed-f6fc-958a-f490-c7fd0eda5e9e"
  skip_tls_verify = true
}

prov_remote = {
  host     = "192.168.255.20"
  port     = 22
  user     = "podmgr"
  password = "podmgr"
}

podman_quadlet = {
  dir = "/home/podmgr/.config/containers/systemd"
  files = [
    {
      template = "./podman-traefik/traefik.container"
      vars = {
        # unit
        Description   = "Traefik Proxy"
        Documentation = "https://docs.traefik.io"
        # service
        ExecStartPre_vault  = "curl -fLsSk --retry-all-errors --retry 5 --retry-delay 30 https://vault.day0.sololab/v1/identity/oidc/.well-known/openid-configuration"
        ExecStartPre_consul = "curl -fLsSk --retry-all-errors --retry 5 --retry-delay 30 https://consul.day0.sololab/v1/catalog/services"
        ExecStartPost       = "/bin/bash -c \"sleep $(shuf -i 8-13 -n 1) && podman healthcheck run traefik\""
        # container
        PodmanArgs = "--tls-verify=false"
        Network    = "host"
        # Network    = "podman"
        # Network = "pasta:--map-host-loopback=169.254.1.3"
        Restart = "on-failure"
      }
    },
  ]
  service = {
    name   = "traefik"
    status = "start"
  }
}

prov_pdns = {
  api_key    = "powerdns"
  server_url = "https://pdns-auth.day0.sololab"
}

dns_records = [
  {
    zone = "day1.sololab."
    name = "traefik.day1.sololab."
    type = "CNAME"
    ttl  = 86400
    records = [
      "day1.node.consul."
    ]
  },
]
