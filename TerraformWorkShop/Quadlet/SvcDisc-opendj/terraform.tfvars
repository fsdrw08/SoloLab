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
    tls_value_sets = {
      name = "opendj.ssl.contents_b64.\"keystore\\.p12\""
      value_ref = {
        vault_kvv2 = {
          mount = "kvv2/certs"
          name  = "opendj.day1.sololab"
          data_key = {
            ca          = "ca"
            cert        = "cert"
            private_key = "private_key"
          }
        }
      }
    }
  }
  manifest_dest_path = "/home/podmgr/.config/containers/systemd/opendj-aio.yaml"
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

post_process = {
  "Enable-PreEncodedPassword.sh" = {
    script_path = "./podman-opendj/Enable-PreEncodedPassword.sh"
    vars = {
      CONTAINER_NAME = "opendj-opendj"
      hostname       = "localhost"
      bindDN         = "cn=Directory Manager"
      bindPassword   = "P@ssw0rd"
    }
  }
}

prov_pdns = {
  api_key    = "powerdns"
  server_url = "https://pdns.day0.sololab"
}

dns_record = {
  zone = "day1.sololab."
  name = "opendj.day1.sololab."
  type = "A"
  ttl  = 86400
  records = [
    "192.168.255.20"
  ]
}
