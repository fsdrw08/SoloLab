prov_remote = {
  host     = "192.168.255.10"
  port     = 22
  user     = "podmgr"
  password = "podmgr"
}

prov_vault = {
  schema          = "https"
  address         = "vault.day1.sololab:8200"
  token           = "95eba8ed-f6fc-958a-f490-c7fd0eda5e9e"
  skip_tls_verify = true
}

podman_quadlet = {
  dir = "/home/podmgr/.config/containers/systemd"
  units = [
    {
      files = [
        {
          template = "./attachments/whoami.container"
          # https://stackoverflow.com/questions/63180277/terraform-map-with-string-and-map-elements-possible
          vars = {
            # unit
            Description           = "Tiny Go webserver that prints OS information and HTTP request to output."
            Documentation         = "https://github.com/traefik/whoami, https://hub.docker.com/r/traefik/whoami"
            After                 = ""
            Wants                 = ""
            StartLimitIntervalSec = 120
            StartLimitBurst       = 3
            # kube
            yaml          = "whoami-aio.yaml"
            KubeDownForce = "false"
            # podman
            PodmanArgs = "--tls-verify=false"
            Network    = "host"
            # service
            ExecStartPre  = ""
            ExecStartPost = ""
            Restart       = "no"
          }
        },
      ]
      service = {
        name   = "whoami-container"
        status = "start"
      }
    },
  ]
}
