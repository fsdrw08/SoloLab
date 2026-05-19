prov_vault = {
  address         = "https://vault.day1.sololab"
  token           = "95eba8ed-f6fc-958a-f490-c7fd0eda5e9e"
  skip_tls_verify = true
}

prov_remote = {
  host     = "192.168.255.10"
  port     = 22
  user     = "podmgr"
  password = "podmgr"
}

podman_kubes = [
  {
    helm = {
      name       = "pd"
      chart      = "../../../HelmWorkShop/helm-charts/charts/pd"
      value_file = "./attachments-pd/values-sololab.yaml"
    }
    manifest_dest_path = "/home/podmgr/.config/containers/systemd/pd-aio.yaml"
  },
  {
    helm = {
      name       = "tikv"
      chart      = "../../../HelmWorkShop/helm-charts/charts/tikv"
      value_file = "./attachments-tikv/values-sololab.yaml"
    }
    manifest_dest_path = "/home/podmgr/.config/containers/systemd/tikv-aio.yaml"
  }
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
            Description           = "PD is the abbreviation for Placement Driver. It is used to manage and schedule the TiKV cluster."
            Documentation         = "https://github.com/tikv/pd/tree/master"
            After                 = ""
            Wants                 = ""
            StartLimitIntervalSec = 120
            StartLimitBurst       = 5
            Before                = "umount.target"
            Conflicts             = "umount.target"
            # kube
            yaml          = "pd-aio.yaml"
            PodmanArgs    = "--tls-verify=false"
            KubeDownForce = "false"
            Network       = "host"
            # service
            ExecStartPre  = ""
            ExecStartPost = "/bin/bash -c \"sleep $(shuf -i 8-13 -n 1) && podman healthcheck run pd-server\""
            Restart       = "on-failure"
          }
        },
      ]
      service = {
        name   = "pd"
        status = "start"
      }
    },
    {
      files = [
        {
          template = "../templates/quadlet.kube"
          vars = {
            # unit
            Description           = "Distributed transactional key-value database, originally created to complement TiDB"
            Documentation         = "https://github.com/tikv/tikv/tree/master"
            After                 = ""
            Wants                 = ""
            StartLimitIntervalSec = 120
            StartLimitBurst       = 5
            Before                = "umount.target"
            Conflicts             = "umount.target"
            # kube
            yaml          = "tikv-aio.yaml"
            PodmanArgs    = "--tls-verify=false"
            KubeDownForce = "false"
            Network       = "host"
            # service
            ExecStartPre  = "/bin/bash -c \"curl -fLsSk --retry-all-errors --retry 20 --retry-delay 30 https://pd.day1.sololab/pd/api/v1/members\""
            ExecStartPost = ""
            # ExecStartPost = "/bin/bash -c \"sleep $(shuf -i 8-13 -n 1) && podman healthcheck run tikv-server\""
            Restart = "on-failure"
          }
        },
      ]
      service = {
        name   = "tikv"
        status = "start"
      }
    },
  ]
}
