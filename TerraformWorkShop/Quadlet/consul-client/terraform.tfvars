prov_remote = {
  host     = "192.168.255.20"
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
    #     name         = "consul.configFiles.main.node_name"
    #     value_string = "day1"
    #   },
    #   {
    #     name         = "consul.configFiles.main.auto_config.intro_token"
    #     value_string = "eyJhbGciOiJSUzI1NiIsImtpZCI6IjJiYzY0NDBlLTk5MzMtYzZlZS1mYmU1LTg2N2ZjOGVkZGMxNiJ9.eyJhdWQiOiJjb25zdWwtY2x1c3Rlci1kYzEiLCJjb25zdWwiOnsiaG9zdG5hbWUiOiJkYXkxIn0sImV4cCI6MTc0NTU4NDUwMywiaWF0IjoxNzQ1NTU1NzAzLCJpc3MiOiJodHRwczovL3ZhdWx0LmRheTAuc29sb2xhYjo4MjAwL3YxL2lkZW50aXR5L29pZGMiLCJuYW1lc3BhY2UiOiJyb290Iiwic3ViIjoiOWY3YjU4ZjItYTUxYS00ZWJhLTRlMWUtOTNmOThjNmM0YzVmIn0.KxCZOJzBuDxZ78rrAeIaNPIQOam22GDnQPNKdHVgtgnYoxmeb6FUWRYl-tOR8XfIA9KdARLFEONJrV0i-SHtoS7kS52kVKZf6E1XPVJkSPaPRDhIpZKvTZQq2IV8bd7dPY6uAIO2u2ZcWPczzBg_T9I4NC7WCgjTQ1N1y4IrJM9KI6P3_61kw2AlMJR67XY1Y_tTBp6Hu7HiSEku-v2Xc0Ppkn9Hn4-6coiA0VfSUrYPPNrdIGOZGWDhgaNEa_EEym1N1zHbDTWUDb3EfYLM0otZ2qxvQIY3p9ID9niKE5mTGJ5EO4FqUAgx-BvtE1AH8sHHUFvA5krJXALX-QTzOQ"
    #   },
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
          name          = "consul.tls.contents.ca\\.crt"
          value_ref_key = "ca"
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
        After         = ""
        Wants         = ""
        yaml          = "consul-aio.yaml"
        PodmanArgs    = "--tls-verify=false"
        KubeDownForce = "false"
        Network       = "host"
        # wait until vault oidc ready
        # ref: https://github.com/vmware-tanzu/pinniped/blob/b8b460f98a35d69a99d66721c631a8c2bd438d2c/hack/prepare-supervisor-on-kind.sh#L502
        ExecStartPre = "curl -fLsSk --retry-all-errors --retry 5 --retry-delay 30 https://vault.day0.sololab:8200/v1/identity/oidc/.well-known/openid-configuration"
      }
      dir = "/home/podmgr/.config/containers/systemd"
    }
  ]
  service = {
    name   = "consul-container"
    status = "start"
  }
}

# post_process = {
#   "Enable-DNSAnonymousAccess.sh" = {
#     script_path = "./podman-consul/Enable-DNSAnonymousAccess.sh"
#     vars = {
#       CONSUL_HTTP_ADDR = "https://consul.day0.sololab:8501"
#       INIT_TOKEN       = "e95b599e-166e-7d80-08ad-aee76e7ddf19"
#     }
#   }
# }

prov_pdns = {
  api_key    = "powerdns"
  server_url = "https://pdns-auth.day0.sololab"
}

# dns_records = [
#   {
#     zone = "day0.sololab."
#     name = "consul-client.day1.sololab."
#     type = "A"
#     ttl  = 86400
#     records = [
#       "192.168.255.20"
#     ]
#   },
# ]
