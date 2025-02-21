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
    name       = "nomad"
    chart      = "../../../HelmWorkShop/helm-charts/charts/nomad"
    value_file = "./podman-nomad/values-sololab.yaml"
    value_sets = [
      {
        name         = "nomad.configFiles.main.advertise.http"
        value_string = "192.168.255.20"
      },
      {
        name         = "nomad.configFiles.main.advertise.rpc"
        value_string = "192.168.255.20"
      },
      {
        name         = "nomad.configFiles.main.advertise.serf"
        value_string = "192.168.255.20"
      },
    ]
    tls_value_sets = {
      value_ref = {
        vault_kvv2 = {
          mount = "kvv2/certs"
          name  = "nomad.day1.sololab"
        }
      }
      value_sets = [
        {
          name          = "nomad.tls.contents.\"ca\\.crt\""
          value_ref_key = "ca"
        },
        {
          name          = "nomad.tls.contents.\"server\\.crt\""
          value_ref_key = "cert"
        },
        {
          name          = "nomad.tls.contents.\"server\\.key\""
          value_ref_key = "private_key"
        },
      ]
    }
  }
  manifest_dest_path = "/home/podmgr/.config/containers/systemd/nomad-aio.yaml"
}

podman_quadlet = {
  quadlet = {
    file_contents = [
      {
        file_source = "./podman-nomad/nomad-container.kube"
        # https://stackoverflow.com/questions/63180277/terraform-map-with-string-and-map-elements-possible
        vars = {
          yaml          = "nomad-aio.yaml"
          PodmanArgs    = "--tls-verify=false --ip=10.89.0.254"
          ExecStartPre  = "sleep 3"
          KubeDownForce = "false"
        }
      },
    ]
    file_path_dir = "/home/podmgr/.config/containers/systemd"
  }
  service = {
    name   = "nomad-container"
    status = "start"
  }
}

container_restart = {
  systemd_path_unit = {
    content = {
      templatefile = "./podman-nomad/restart.path"
      vars = {
        PathModified = "/home/podmgr/.config/containers/systemd/nomad-aio.yaml"
      }
    }
    path = "/home/podmgr/.config/systemd/user/nomad_restart.path"
  }
  systemd_service_unit = {
    content = {
      templatefile = "./podman-nomad/restart.service"
      vars = {
        AssertPathExists = "/run/user/1001/systemd/generator/nomad-container.service"
        target_service   = "nomad-container.service"
      }
    }
    path = "/home/podmgr/.config/systemd/user/nomad_restart.service"
  }

}

post_process = {
  "New-NomadAnonymousPolicy.sh" = {
    script_path = "./podman-nomad/New-NomadAnonymousPolicy.sh"
    vars = {
      NOMAD_ADDR       = "https://nomad.day1.sololab:4646"
      NOMAD_TOKEN_FILE = "/var/home/podmgr/.local/share/containers/storage/volumes/nomad-pvc/_data/server/nomad_token"
    }
  }
}

prov_pdns = {
  api_key    = "powerdns"
  server_url = "https://pdns.day0.sololab"
}

dns_record = {
  zone = "day1.sololab."
  name = "nomad.day1.sololab."
  type = "A"
  ttl  = 86400
  records = [
    "192.168.255.20"
  ]
}
