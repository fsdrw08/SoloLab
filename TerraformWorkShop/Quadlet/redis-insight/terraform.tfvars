prov_remote = {
  host     = "192.168.255.20"
  port     = 22
  user     = "podmgr"
  password = "podmgr"
}

prov_vault = {
  schema          = "https"
  address         = "vault.day0.sololab"
  token           = "95eba8ed-f6fc-958a-f490-c7fd0eda5e9e"
  skip_tls_verify = true
}

podman_kubes = [
  {
    helm = {
      name       = "redis-insight"
      chart      = "../../../HelmWorkShop/helm-charts/charts/redis-insight"
      value_file = "./attachments/values-sololab.yaml"
    }
    manifest_dest_path = "/home/podmgr/.config/containers/systemd/redis-insight-aio.yaml"
  },
]

podman_quadlet = {
  dir = "/home/podmgr/.config/containers/systemd"
  units = [
    {
      files = [
        {
          template = "../templates/quadlet.kube"
          # https://stackoverflow.com/questions/63180277/terraform-map-with-string-and-map-elements-possible
          vars = {
            # unit
            Description           = "Redis GUI by Redis"
            Documentation         = "https://redis.io/docs/latest/operate/redisinsight/"
            After                 = ""
            Wants                 = ""
            StartLimitIntervalSec = 120
            StartLimitBurst       = 3
            Before                = "umount.target"
            Conflicts             = "umount.target"
            # podman
            PodmanArgs = "--tls-verify=false"
            Network    = ""
            # kube
            yaml          = "redis-insight-aio.yaml"
            KubeDownForce = "false"
            # service
            ExecStartPre  = ""
            ExecStartPost = "/bin/bash -c \"sleep $(shuf -i 50-60 -n 1) && podman healthcheck run redis-insight-server\""
            Restart       = "on-failure"
          }
        },
      ]
      service = {
        name   = "redis-insight"
        status = "start"
      }
    },
  ]
}
