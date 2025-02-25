prov_remote = {
  host     = "192.168.255.20"
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

podman_kube = {
  helm = {
    name       = "traefik"
    chart      = "../../../HelmWorkShop/helm-charts/charts/traefik"
    value_file = "./podman-traefik/values-sololab.yaml"
    tls_value_sets = {
      value_ref = {
        vault_kvv2 = {
          mount = "kvv2/certs"
          name  = "traefik.day1.sololab"
        }
      }
      value_sets = [
        {
          name          = "traefik.tls.contents.\"ca\\.crt\""
          value_ref_key = "ca"
        },
        {
          name          = "traefik.tls.contents.\"dashboard\\.crt\""
          value_ref_key = "cert"
        },
        {
          name          = "traefik.tls.contents.\"dashboard\\.key\""
          value_ref_key = "private_key"
        },
      ]
    }
  }
  manifest_dest_path = "/home/podmgr/.config/containers/systemd/traefik-aio.yaml"
}

podman_quadlet = {
  # quadlet = {
  #   file_contents = [
  #     {
  #       file_source = "./podman-traefik/traefik-container.container"
  #       # https://stackoverflow.com/questions/63180277/terraform-map-with-string-and-map-elements-possible
  #       vars = {
  #         # yaml          = "traefik-aio.yaml"
  #         PodmanArgs = "--tls-verify=false"
  #         # KubeDownForce = "false"
  #       }
  #     },
  #   ]
  #   file_path_dir = "/home/podmgr/.config/containers/systemd"
  # }
  service = {
    name   = "traefik-container"
    status = "start"
  }
  files = [
    {
      template = "./podman-traefik/traefik-container.container"
      vars = {
        # yaml          = "vault-aio.yaml"
        PodmanArgs = "--tls-verify=false"
        # KubeDownForce = "false"
        ca   = 123
        cert = 123
        key  = 123
      }
      dir = "/home/podmgr/.config/containers/systemd"
    }
  ]
}

container_restart = {
  systemd_unit_files = [
    {
      content = {
        templatefile = "./podman-traefik/restart.path"
        vars = {
          PathModified = "/home/podmgr/.config/containers/systemd/traefik-aio.yaml"
        }
      }
      path = "/home/podmgr/.config/systemd/user/traefik_restart.path"
    },
    {
      content = {
        templatefile = "./podman-traefik/restart.service"
        vars = {
          AssertPathExists = "/run/user/1001/systemd/generator/traefik-container.service"
          target_service   = "traefik-container.service"
        }
      }
      path = "/home/podmgr/.config/systemd/user/traefik_restart.service"
    }
  ]

  systemd_unit_name = "traefik_restart"

}

prov_pdns = {
  api_key    = "powerdns"
  server_url = "https://pdns.day0.sololab"
}

dns_record = {
  zone = "day1.sololab."
  name = "traefik.day1.sololab."
  type = "A"
  ttl  = 86400
  records = [
    "192.168.255.20"
  ]
}
