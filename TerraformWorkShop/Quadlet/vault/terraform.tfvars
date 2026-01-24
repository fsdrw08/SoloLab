prov_remote = {
  host     = "192.168.255.10"
  port     = 22
  user     = "podmgr"
  password = "podmgr"
}

podman_kubes = [
  {
    helm = {
      name       = "vault"
      chart      = "../../../HelmWorkShop/helm-charts/charts/vault"
      value_file = "./attachments/values-sololab.yaml"
      value_refers = [
        {
          tfstate = {
            backend = {
              type = "local"
              config = {
                path = "../../TLS/RootCA/terraform.tfstate"
              }
            }
            cert_name = "vault.day0"
          }
          value_sets = [
            {
              name          = "vault.secret.tls.contents.ca\\.crt"
              value_ref_key = "ca"
            },
            {
              name          = "vault.secret.tls.contents.tls\\.crt"
              value_ref_key = "cert_pem_chain"
            },
            {
              name          = "vault.secret.tls.contents.tls\\.key"
              value_ref_key = "key_pem"
            }
          ]
        }
      ]
    }
    manifest_dest_path = "/home/podmgr/.config/containers/systemd/vault-aio.yaml"
  }
]
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
            Before                = "umount.target"
            Conflicts             = "umount.target"
            # podman
            PodmanArgs = "--tls-verify=false"
            Network    = ""
            # kube
            yaml          = "vault-aio.yaml"
            KubeDownForce = "false"
            # service
            ExecStartPre  = ""
            ExecStartPost = "/bin/bash -c \"sleep $(shuf -i 20-30 -n 1) && podman healthcheck run vault-server\""
            # ExecStartPost = ""
            Restart = "on-failure"
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

post_process = {
  New-VaultStaticToken = {
    script_path = "./attachments/New-VaultStaticToken.sh"
    vars = {
      VAULT_OPERATOR_SECRETS_JSON_PATH = "/home/podmgr/.local/share/containers/storage/volumes/vault-pvc-unseal/_data/vault_operator_secrets_b64"
      # VAULT_OPERATOR_SECRETS_PATH = "/home/podmgr/.local/share/containers/storage/volumes/vault-pvc-file/_data/vault_operator_secret"
      VAULT_ADDR   = "https://localhost:8200"
      STATIC_TOKEN = "95eba8ed-f6fc-958a-f490-c7fd0eda5e9e"
    }
  }
}
