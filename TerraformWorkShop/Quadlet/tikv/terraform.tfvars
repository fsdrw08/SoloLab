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

}]

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
  ]
}
