prov_remote = {
  host     = "192.168.255.20"
  port     = 22
  user     = "podmgr"
  password = "podmgr"
}

certs_ref = {
  tfstate = {
    backend = "local"
    config = {
      path = "../../TLS/RootCA/terraform.tfstate"
    }
    entity = "keycloak"
  }
  config_node = {
    cert = "keycloak.ssl.contents.\"tls\\.crt\""
    key  = "keycloak.ssl.contents.\"tls\\.key\""
  }
}

podman_kube = {
  helm = {
    name       = "keycloak"
    chart      = "../../../HelmWorkShop/helm-charts/charts/keycloak"
    value_file = "./podman-keycloak/values-sololab.yaml"
  }
  yaml_file_path = "/home/podmgr/.config/containers/systemd/keycloak-aio.yaml"
}

podman_quadlet = {
  quadlet = {
    file_contents = [
      {
        file_source = "./podman-keycloak/keycloak-container.kube"
        # https://stackoverflow.com/questions/63180277/terraform-map-with-string-and-map-elements-possible
        vars = {
          yaml          = "keycloak-aio.yaml"
          PodmanArgs    = "--tls-verify=false"
          KubeDownForce = "false"
        }
      },
    ]
    file_path_dir = "/home/podmgr/.config/containers/systemd"
  }
  service = {
    name   = "keycloak-container"
    status = "start"
  }
}

container_restart = {
  systemd_path_unit = {
    content = {
      templatefile = "./podman-keycloak/restart.path"
      vars = {
        PathModified = "/home/podmgr/.config/containers/systemd/keycloak-aio.yaml"
      }
    }
    path = "/home/podmgr/.config/systemd/user/keycloak_restart.path"
  }
  systemd_service_unit = {
    content = {
      templatefile = "./podman-keycloak/restart.service"
      vars = {
        AssertPathExists = "/run/user/1001/systemd/generator/keycloak-container.service"
        target_service   = "keycloak-container.service"
      }
    }
    path = "/home/podmgr/.config/systemd/user/keycloak_restart.service"
  }

}

prov_pdns = {
  api_key    = "powerdns"
  server_url = "https://pdns.day0.sololab"
}

dns_record = {
  zone = "day1.sololab."
  name = "keycloak.day1.sololab."
  type = "A"
  ttl  = 86400
  records = [
    "192.168.255.20"
  ]
}
