prov_remote = {
  host     = "192.168.255.20"
  port     = 22
  user     = "podmgr"
  password = "podmgr"
}

podman_kube = {
  helm = {
    name       = "vault"
    chart      = "../../../HelmWorkShop/helm-charts/charts/vault"
    value_file = "./podman-vault/values-sololab.yaml"
    tls_value_sets = {
      name = {
        ca          = "vault.tls.contents.\"ca\\.crt\""
        cert        = "vault.tls.contents.\"tls\\.crt\""
        private_key = "vault.tls.contents.\"tls\\.key\""
      }
      value_ref = {
        tfstate = {
          backend = {
            type = "local"
            config = {
              path = "../../TLS/RootCA/terraform.tfstate"
            }
          }
          cert_name = "vault"
        }
      }
    }
  }
  manifest_dest_path = "/home/podmgr/.config/containers/systemd/vault-aio.yaml"
}

podman_quadlet = {
  files = [
    {
      template = "./podman-vault/vault-container.kube"
      vars = {
        Description   = "HashiCorp Vault - A tool for managing secrets"
        Documentation = "https://developer.hashicorp.com/vault/docs"
        yaml          = "vault-aio.yaml"
        PodmanArgs    = "--tls-verify=false"
        KubeDownForce = "false"
      }
      dir = "/home/podmgr/.config/containers/systemd"
    }
  ]
  service = {
    name   = "vault-container"
    status = "start"
  }
}

prov_pdns = {
  api_key        = "powerdns"
  server_url     = "https://pdns.day0.sololab"
  insecure_https = true
}

dns_record = {
  zone = "day1.sololab."
  name = "vault.day1.sololab."
  type = "A"
  ttl  = 86400
  records = [
    "192.168.255.20"
  ]
}

post_process = {
  New-VaultStaticToken = {
    script_path = "./podman-vault/New-VaultStaticToken.sh"
    vars = {
      VAULT_OPERATOR_SECRETS_JSON_PATH = "/home/podmgr/.local/share/containers/storage/volumes/vault-pvc-unseal/_data/vault_operator_secrets_b64"
      # VAULT_OPERATOR_SECRETS_PATH = "/home/podmgr/.local/share/containers/storage/volumes/vault-pvc-file/_data/vault_operator_secret"
      VAULT_ADDR   = "https://vault.day1.sololab:8200"
      STATIC_TOKEN = "95eba8ed-f6fc-958a-f490-c7fd0eda5e9e"
    }
  }
}
