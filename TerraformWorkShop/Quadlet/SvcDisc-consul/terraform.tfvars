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
    name       = "consul"
    chart      = "../../../HelmWorkShop/helm-charts/charts/consul"
    value_file = "./podman-consul/values-sololab.yaml"
    tls_value_sets = {
      value_ref = {
        vault_kvv2 = {
          mount = "kvv2/certs"
          name  = "consul.day1.sololab"
        }
      }
      value_sets = [
        {
          name          = "consul.configFiles.general.auto_config.authorization.static.oidc_discovery_ca_cert"
          value_ref_key = "ca"
        },
        {
          name          = "consul.tls.contents.\"ca\\.crt\""
          value_ref_key = "ca"
        },
        {
          name          = "consul.tls.contents.\"server\\.crt\""
          value_ref_key = "cert"
        },
        {
          name          = "consul.tls.contents.\"server\\.key\""
          value_ref_key = "private_key"
        },
      ]
    }
  }
  manifest_dest_path = "/home/podmgr/.config/containers/systemd/consul-aio.yaml"
}

podman_quadlet = {
  quadlet = {
    file_contents = [
      {
        file_source = "./podman-consul/consul-container.kube"
        # https://stackoverflow.com/questions/63180277/terraform-map-with-string-and-map-elements-possible
        vars = {
          yaml          = "consul-aio.yaml"
          PodmanArgs    = "--tls-verify=false"
          KubeDownForce = "true"
        }
      },
    ]
    file_path_dir = "/home/podmgr/.config/containers/systemd"
  }
  service = {
    name   = "consul-container"
    status = "start"
  }
}

container_restart = {
  systemd_path_unit = {
    content = {
      templatefile = "./podman-consul/restart.path"
      vars = {
        PathModified = "/home/podmgr/.config/containers/systemd/consul-aio.yaml"
      }
    }
    path = "/home/podmgr/.config/systemd/user/consul_restart.path"
  }
  systemd_service_unit = {
    content = {
      templatefile = "./podman-consul/restart.service"
      vars = {
        AssertPathExists = "/run/user/1001/systemd/generator/consul-container.service"
        target_service   = "consul-container.service"
      }
    }
    path = "/home/podmgr/.config/systemd/user/consul_restart.service"
  }

}

prov_pdns = {
  api_key    = "powerdns"
  server_url = "https://pdns.day0.sololab"
}

dns_record = {
  zone = "day1.sololab."
  name = "consul.day1.sololab."
  type = "A"
  ttl  = 86400
  records = [
    "192.168.255.20"
  ]
}
