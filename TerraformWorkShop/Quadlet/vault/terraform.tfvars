prov_remote = {
  host     = "192.168.255.10"
  port     = 22
  user     = "podmgr"
  password = "podmgr"
}

podman_kube = {
  helm = {
    name       = "vault"
    chart      = "../../../HelmWorkShop/helm-charts/charts/vault"
    value_file = "./podman-vault/values-sololab.yaml"
    tls = {
      value_sets = [
        {
          name          = "vault.tls.contents.ca\\.crt"
          value_ref_key = "ca"
        },
        {
          name          = "vault.tls.contents.tls\\.crt"
          value_ref_key = "cert_pem_chain"
        },
        {
          name          = "vault.tls.contents.tls\\.key"
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
        cert_name = "vault"
      }
    }
  }
  manifest_dest_path = "/home/podmgr/.config/containers/systemd/vault-aio.yaml"
}

podman_quadlet = {
  dir = "/home/podmgr/.config/containers/systemd"
  units = [
    {
      files = [
        {
          template = "../templates/quadlet.kube"
          vars = {
            # unit
            Description           = "HashiCorp Vault - A tool for managing secrets"
            Documentation         = "https://developer.hashicorp.com/vault/docs"
            After                 = ""
            Wants                 = ""
            StartLimitIntervalSec = 120
            StartLimitBurst       = 3
            # kube
            yaml          = "vault-aio.yaml"
            PodmanArgs    = "--tls-verify=false"
            KubeDownForce = "false"
            Network       = "host"
            # service
            ExecStartPre  = ""
            ExecStartPost = "/bin/bash -c \"sleep $(shuf -i 15-20 -n 1) && podman healthcheck run vault-server\""
            Restart       = "on-failure"
          }
        }
      ]
      service = {
        name   = "vault"
        status = "start"
      }
    },
  ]
}

prov_pdns = {
  api_key        = "powerdns"
  server_url     = "https://pdns-auth.day0.sololab"
  insecure_https = true
}

dns_records = [{
  zone = "day0.sololab."
  name = "vault.day0.sololab."
  type = "A"
  ttl  = 86400
  records = [
    "192.168.255.10"
  ]
}]

post_process = {
  New-VaultStaticToken = {
    script_path = "./podman-vault/New-VaultStaticToken.sh"
    vars = {
      VAULT_OPERATOR_SECRETS_JSON_PATH = "/home/podmgr/.local/share/containers/storage/volumes/vault-pvc-unseal/_data/vault_operator_secrets_b64"
      # VAULT_OPERATOR_SECRETS_PATH = "/home/podmgr/.local/share/containers/storage/volumes/vault-pvc-file/_data/vault_operator_secret"
      VAULT_ADDR   = "https://192.168.255.10:8200"
      STATIC_TOKEN = "95eba8ed-f6fc-958a-f490-c7fd0eda5e9e"
    }
  }
}
