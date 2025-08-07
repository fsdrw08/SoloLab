prov_vault = {
  address         = "https://vault.day1.sololab"
  token           = "95eba8ed-f6fc-958a-f490-c7fd0eda5e9e"
  skip_tls_verify = true
}

prov_remote = {
  host     = "192.168.255.20"
  port     = 22
  user     = "podmgr"
  password = "podmgr"
}

podman_kubes = [
  {
    helm = {
      name       = "gitea-redis"
      chart      = "../../../HelmWorkShop/helm-charts/charts/redis"
      value_file = "./podman-redis/values-sololab.yaml"
    }
    manifest_dest_path = "/home/podmgr/.config/containers/systemd/gitea-redis-aio.yaml"
  },
]

podman_quadlet = {
  dir = "/home/podmgr/.config/containers/systemd"
  units = [
    {
      files = [
        {
          template = "../templates/quadlet.kube"
          vars = {
            # unit
            Description           = "Redis data structure server"
            Documentation         = "https://redis.io/documentation"
            After                 = ""
            Wants                 = ""
            StartLimitIntervalSec = 120
            StartLimitBurst       = 3
            # kube
            yaml          = "gitea-redis-aio.yaml"
            KubeDownForce = "false"
            PodmanArgs    = "--tls-verify=false"
            Network       = "host"
            # service
            ExecStartPre = ""
            ## https://community.grafana.com/t/ingester-is-not-ready-automatically-until-a-call-to-ready/100891/4
            ExecStartPost = "/bin/bash -c \"sleep $(shuf -i 8-12 -n 1) && podman healthcheck run gitea-redis-server\""
            Restart       = "on-failure"
          }
        },
      ]
      service = {
        name   = "gitea-redis"
        status = "start"
      }
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
    name = "gitea-redis.day1.sololab."
    type = "CNAME"
    ttl  = 86400
    records = [
      "Day1-FCOS.node.consul."
    ]
  },
]
