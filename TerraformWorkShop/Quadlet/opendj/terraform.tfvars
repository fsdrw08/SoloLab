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
        # vault_kvv2 = {
        #   mount = "kvv2/certs"
        #   name  = "opendj.day1.sololab"
        #   data_key = {
        #     ca          = "ca"
        #     cert        = "cert"
        #     private_key = "private_key"
        #   }
        # }
        tfstate = {
          backend = {
            type = "local"
            config = {
              path = "../../TLS/RootCA/terraform.tfstate"
            }
          }
          cert_name = "opendj"
        }
      }
    }
  }
  manifest_dest_path = "/home/podmgr/.config/containers/systemd/opendj-aio.yaml"
}

podman_quadlet = {
  files = [
    {
      template = "./podman-opendj/opendj-container.kube"
      vars = {
        Description   = "OpenDJ is an LDAPv3 compliant directory service, which has been developed for the Java platform, providing a high performance, highly available, and secure store for the identities managed by your organization"
        Documentation = "https://github.com/OpenIdentityPlatform/OpenDJ"
        yaml          = "opendj-aio.yaml"
        PodmanArgs    = "--tls-verify=false"
        KubeDownForce = "false"
      }
      dir = "/home/podmgr/.config/containers/systemd"
    }
  ]
  service = {
    name   = "opendj-container"
    status = "start"
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
