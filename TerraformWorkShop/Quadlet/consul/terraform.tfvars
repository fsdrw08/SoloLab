prov_remote = {
  host     = "192.168.255.10"
  port     = 22
  user     = "podmgr"
  password = "podmgr"
}

prov_vault = {
  schema          = "https"
  address         = "vault.day0.sololab:8200"
  token           = "95eba8ed-f6fc-958a-f490-c7fd0eda5e9e"
  skip_tls_verify = true
}

podman_kube = {
  helm = {
    name       = "consul"
    chart      = "../../../HelmWorkShop/helm-charts/charts/consul"
    value_file = "./podman-consul/values-sololab.yaml"
    # value_sets = [
    #   {
    #     name         = "consul.configFiles.main.advertise_addr"
    #     value_string = "192.168.255.20"
    #   }
    # ]
    tls = {
      tfstate = {
        backend = {
          type = "local"
          config = {
            path = "../../TLS/RootCA/terraform.tfstate"
          }
        }
        cert_name = "consul"
      }
      value_sets = [
        {
          name          = "consul.configFiles.main.auto_config.authorization.static.oidc_discovery_ca_cert"
          value_ref_key = "ca"
        },
        {
          name          = "consul.tls.contents.ca\\.crt"
          value_ref_key = "ca"
        },
        {
          name          = "consul.tls.contents.server\\.crt"
          value_ref_key = "cert_pem"
        },
        {
          name          = "consul.tls.contents.server\\.key"
          value_ref_key = "key_pem"
        },
      ]
    }
  }
  manifest_dest_path = "/home/podmgr/.config/containers/systemd/consul-aio.yaml"
}

podman_quadlet = {
  files = [
    {
      template = "./podman-consul/consul-container.kube"
      vars = {
        Description   = "Consul is a multi-networking tool that offers a fully-featured service mesh solution."
        Documentation = "https://developer.hashicorp.com/consul/docs"
        After         = "vault-container.service"
        Wants         = "vault-container.service"
        yaml          = "consul-aio.yaml"
        PodmanArgs    = "--tls-verify=false"
        KubeDownForce = "false"
        Network       = "host"
        ExecStartPre  = "curl -fLsSk --retry-all-errors --retry 5 --retry-delay 30 https://vault.day0.sololab:8200/v1/identity/oidc/.well-known/openid-configuration"
      }
      dir = "/home/podmgr/.config/containers/systemd"
    }
  ]
  service = {
    name   = "consul-container"
    status = "start"
  }
}

post_process = {
  "Enable-DNSAnonymousAccess.sh" = {
    script_path = "./podman-consul/Enable-DNSAnonymousAccess.sh"
    vars = {
      CONSUL_HTTP_ADDR = "https://consul.day0.sololab:8501"
      INIT_TOKEN       = "e95b599e-166e-7d80-08ad-aee76e7ddf19"
    }
  }
}

prov_pdns = {
  api_key    = "powerdns"
  server_url = "https://pdns-auth.day0.sololab"
}

dns_record = {
  zone = "day0.sololab."
  name = "consul.day0.sololab."
  type = "A"
  ttl  = 86400
  records = [
    "192.168.255.10"
  ]
}
