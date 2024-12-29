vm_conn = {
  host     = "192.168.255.20"
  port     = 22
  user     = "podmgr"
  password = "podmgr"
}

certs = {
  cert_content_tfstate_ref    = "../../TLS/RootCA/terraform.tfstate"
  cert_content_tfstate_entity = "opendj"
  # cacert_basename          = "ca.crt"
  # cert_value_path          = "server.crt"
  # key_value_path           = "server.key"
}

podman_kube = {
  helm = {
    name       = "opendj"
    chart      = "../../../HelmWorkShop/helm-charts/charts/opendj"
    value_file = "./podman-opendj/values-sololab.yaml"
    value_sets = [
      {
        name                = "opendj.schemas.\"44-domain_base\\.ldif\""
        value_template_path = "./podman-opendj/44-domain_base.ldif"
        value_template_vars = {
          baseDN = "dc=root\\,dc=sololab"
        }
      },
      {
        name                = "opendj.schemas.\"45-groups\\.ldif\""
        value_template_path = "./podman-opendj/45-groups.ldif"
        value_template_vars = {
          baseDN = "dc=root\\,dc=sololab"
        }
      },
      {
        name                = "opendj.schemas.\"46-people\\.ldif\""
        value_template_path = "./podman-opendj/46-people.ldif"
        value_template_vars = {
          baseDN = "dc=root\\,dc=sololab"
        }
      },
      {
        name                = "opendj.schemas.\"47-services\\.ldif\""
        value_template_path = "./podman-opendj/47-services.ldif"
        value_template_vars = {
          baseDN = "dc=root\\,dc=sololab"
        }
      },
    ]
  }
  yaml_file_path = "/home/podmgr/.config/containers/systemd/opendj-aio.yaml"
}

podman_quadlet = {
  quadlet = {
    file_contents = [
      {
        file_source = "./podman-opendj/opendj-container.kube"
        # https://stackoverflow.com/questions/63180277/terraform-map-with-string-and-map-elements-possible
        vars = {
          yaml          = "opendj-aio.yaml"
          PodmanArgs    = "--tls-verify=false"
          KubeDownForce = "false"
        }
      },
    ]
    file_path_dir = "/home/podmgr/.config/containers/systemd"
  }
  service = {
    name   = "opendj-container"
    status = "start"
  }
}

container_restart = {
  systemd_path_unit = {
    content = {
      templatefile = "./podman-opendj/restart.path"
      vars = {
        PathModified = "/home/podmgr/.config/containers/systemd/opendj-aio.yaml"
      }
    }
    path = "/home/podmgr/.config/systemd/user/opendj_restart.path"
  }
  systemd_service_unit = {
    content = {
      templatefile = "./podman-opendj/restart.service"
      vars = {
        AssertPathExists = "/run/user/1001/systemd/generator/opendj-container.service"
        target_service   = "opendj-container.service"
      }
    }
    path = "/home/podmgr/.config/systemd/user/opendj_restart.service"
  }

}
