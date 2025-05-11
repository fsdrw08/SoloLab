prov_remote = {
  host     = "192.168.255.10"
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

podman_kube = {
  helm = {
    # name       = "example-app"
    # chart      = "../../../HelmWorkShop/helm-charts/charts/example-app"
    value_file = "./podman-example-app/values-sololab.yaml"
    # value_sets = [
    #   {
    #     name         = "example-app.configFiles.main.advertise.http"
    #     value_string = "192.168.255.20"
    #   },
    #   {
    #     name         = "example-app.configFiles.main.advertise.rpc"
    #     value_string = "192.168.255.20"
    #   },
    #   {
    #     name         = "example-app.configFiles.main.advertise.serf"
    #     value_string = "192.168.255.20"
    #   },
    # ]
    # tls_value_sets = {
    #   value_ref = {
    #     vault_kvv2 = {
    #       mount = "kvv2/certs"
    #       name  = "example-app.day1.sololab"
    #     }
    #   }
    #   value_sets = [
    #     {
    #       name          = "example-app.tls.contents.ca\\.crt"
    #       value_ref_key = "ca"
    #     },
    #     {
    #       name          = "example-app.tls.contents.server\\.crt"
    #       value_ref_key = "cert"
    #     },
    #     {
    #       name          = "example-app.tls.contents.server\\.key"
    #       value_ref_key = "private_key"
    #     },
    #   ]
    # }
  }
  manifest_dest_path = "/home/podmgr/.config/containers/systemd/example-app-aio.yaml"
}

podman_quadlet = {
  dir = "/home/podmgr/.config/containers/systemd"
  files = [
    {
      template = "../templates/quadlet.kube"
      # https://stackoverflow.com/questions/63180277/terraform-map-with-string-and-map-elements-possible
      vars = {
        # unit
        Description           = "Example app from dex idp project to debug jwt"
        Documentation         = "https://brian-candler.medium.com/using-vault-as-an-openid-connect-identity-provider-ee0aaef2bba2"
        After                 = ""
        Wants                 = ""
        StartLimitIntervalSec = 5
        StartLimitBurst       = 3
        # kube
        yaml          = "example-app-aio.yaml"
        PodmanArgs    = "--tls-verify=false"
        KubeDownForce = "false"
        Network       = "host"
        # service
        ExecStartPre  = ""
        ExecStartPost = ""
        Restart       = "never"
      }
    },
  ]
  service = {
    name   = "example-app"
    status = "start"
  }
}

prov_pdns = {
  api_key    = "powerdns"
  server_url = "https://pdns-auth.day0.sololab"
}

dns_record = {
  zone = "day0.sololab."
  name = "example-app.day0.sololab."
  type = "A"
  ttl  = 86400
  records = [
    "192.168.255.10"
  ]
}
