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
  service = {
    name   = "traefik-container"
    status = "start"
  }
  files = [
    {
      template = "./podman-traefik/traefik-container.container"
      vars = {
        Description         = "Traefik Proxy"
        Documentation       = "https://docs.traefik.io"
        ExecStartPre_vault  = "curl -fLsSk --retry-all-errors --retry 5 --retry-delay 30 https://vault.day0.sololab/v1/identity/oidc/.well-known/openid-configuration"
        ExecStartPre_consul = "curl -fLsSk --retry-all-errors --retry 5 --retry-delay 30 https://consul.day0.sololab/v1/catalog/services"
        PodmanArgs          = "--tls-verify=false"
        Network             = "podman-default-kube-network"
        ExecStartPost       = "/bin/bash -c \"sleep 5 && podman healthcheck run traefik\""
        Restart             = "on-failure"
      }
      dir = "/home/podmgr/.config/containers/systemd"
    },
  ]
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
