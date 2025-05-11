prov_remote = {
  host     = "192.168.255.10"
  port     = 22
  user     = "podmgr"
  password = "podmgr"
}

podman_kube = {
  helm = {
    name       = "lldap"
    chart      = "../../../HelmWorkShop/helm-charts/charts/lldap"
    value_file = "./podman-lldap/values-sololab.yaml"
    value_sets = [
      {
        # https://github.com/microsoft/farmvibes-ai/blob/a9e999fcfaf9a90f147257bbdf7221b8a8b7ce52/src/vibe_core/vibe_core/terraform/local/modules/kubernetes/rabbitmq.tf#L57
        name         = "lldap.extraEnvVars[0].name"
        value_string = "LLDAP_LDAP_PORT"
      },
      {
        name         = "lldap.extraEnvVars[0].value"
        value_string = "389"
      },
      {
        name         = "lldap.extraEnvVars[1].name"
        value_string = "LLDAP_LDAPS_OPTIONS__PORT"
      },
      {
        name         = "lldap.extraEnvVars[1].value"
        value_string = "636"
      },
      {
        name         = "lldap.extraEnvVars[2].name"
        value_string = "TZ"
      },
      {
        name         = "lldap.extraEnvVars[2].value"
        value_string = "Asia/Shanghai"
      },
    ]
    tls = {
      value_sets = [
        {
          name          = "lldap.ssl.contents.cert\\.pem"
          value_ref_key = "cert_pem"
        },
        {
          name          = "lldap.ssl.contents.key\\.pem"
          value_ref_key = "key_pem"
        }
      ]
      tfstate = {
        backend = {
          type = "local"
          config = {
            path = "../../TLS/RootCA/terraform.tfstate"
          }
        }
        cert_name = "lldap"
      }
    }
  }
  manifest_dest_path = "/home/podmgr/.config/containers/systemd/lldap-aio.yaml"
}

podman_quadlet = {
  dir = "/home/podmgr/.config/containers/systemd"
  files = [
    {
      template = "../templates/quadlet.kube"
      vars = {
        # unit
        Description           = "Light LDAP implementation"
        Documentation         = "https://github.com/lldap/lldap"
        After                 = ""
        Wants                 = ""
        StartLimitIntervalSec = 5
        StartLimitBurst       = 3
        # kube
        yaml          = "lldap-aio.yaml"
        PodmanArgs    = "--tls-verify=false"
        KubeDownForce = "false"
        Network       = "host"
        # service
        ExecStartPre  = ""
        ExecStartPost = "/bin/bash -c \"sleep 5 && podman healthcheck run lldap-server\""
        Restart       = "on-failure"
      }
    },
  ]
  service = {
    name   = "lldap"
    status = "start"
  }
}

prov_pdns = {
  api_key    = "powerdns"
  server_url = "http://pdns-auth.day0.sololab:8081"
}

dns_record = {
  zone = "day0.sololab."
  name = "lldap.day0.sololab."
  type = "A"
  ttl  = 86400
  records = [
    "192.168.255.10"
  ]
}
