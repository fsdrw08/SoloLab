resource "null_resource" "init" {
  connection {
    type     = "ssh"
    host     = var.vm_conn.host
    port     = var.vm_conn.port
    user     = var.vm_conn.user
    password = var.vm_conn.password
  }
  triggers = {
    dirs        = "/mnt/data/minio"
    chown_user  = "vyos"
    chown_group = "users"
    chown_dir   = "/mnt/data/minio"
  }
  provisioner "remote-exec" {
    inline = [
      templatefile("${path.root}/minio/init.sh", {
        dirs        = self.triggers.dirs
        chown_user  = self.triggers.chown_user
        chown_group = self.triggers.chown_group
        chown_dir   = self.triggers.chown_dir
      })
    ]
  }
}

data "terraform_remote_state" "root_ca" {
  backend = "local"
  config = {
    path = "../../TLS/RootCA/terraform.tfstate"
  }
}

data "vault_identity_oidc_openid_config" "config" {
  name = "sololab"
}

data "vault_identity_oidc_client_creds" "creds" {
  name = "minio"
}

module "minio" {
  depends_on = [
    null_resource.init,
    data.terraform_remote_state.root_ca,
    data.vault_identity_oidc_client_creds.creds,
    data.vault_identity_oidc_openid_config.config
  ]
  source = "../modules/minio"
  vm_conn = {
    host     = var.vm_conn.host
    port     = var.vm_conn.port
    user     = var.vm_conn.user
    password = var.vm_conn.password
  }
  install = {
    server = {
      # https://dl.min.io/server/minio/release/linux-amd64/archive/
      bin_file_source = "http://sws.infra.sololab:4080/releases/minio.RELEASE.2024%2D03%2D26T22%2D10%2D45Z"
      bin_file_dir    = "/usr/local/bin"
    }
    client = {
      # https://dl.min.io/client/mc/release/linux-amd64/archive/mc.RELEASE.2024-03-25T16-41-14Z
      bin_file_source = "http://sws.infra.sololab:4080/releases/mc.RELEASE.2024%2D03%2D25T16%2D41%2D14Z"
      bin_file_dir    = "/usr/local/bin"
    }
  }
  runas = {
    user        = "vyos"
    group       = "users"
    take_charge = false
  }
  config = {
    env = {
      templatefile_path = "${path.root}/minio/minio.env"
      templatefile_vars = {
        # https://github.com/minio/minio/issues/12992#issuecomment-901941802
        MINIO_OPTS                          = <<EOT
      --address minio.service.consul:9000 \
      --console-address minio.service.consul:9001 \
      --certs-dir /etc/minio/certs
      EOT
        MINIO_VOLUMES                       = "/mnt/data/minio"
        MINIO_ROOT_USER                     = "admin"
        MINIO_ROOT_PASSWORD                 = "P@ssw0rd"
        MINIO_UPDATE                        = "off"
        MINIO_SERVER_URL                    = "https://minio.service.consul"
        MINIO_BROWSER_REDIRECT_URL          = "https://minio.service.consul/ui"
        MINIO_IDENTITY_OPENID_CONFIG_URL    = "${data.vault_identity_oidc_openid_config.config.issuer}/.well-known/openid-configuration"
        MINIO_IDENTITY_OPENID_CLIENT_ID     = data.vault_identity_oidc_client_creds.creds.client_id
        MINIO_IDENTITY_OPENID_CLIENT_SECRET = data.vault_identity_oidc_client_creds.creds.client_secret
        MINIO_IDENTITY_OPENID_CLAIM_NAME    = "groups"
        MINIO_IDENTITY_OPENID_CLAIM_PREFIX  = "minio"
        MINIO_IDENTITY_OPENID_SCOPES        = "openid,username,groups"
      }
    }
    certs = {
      ca_basename = "sololab.crt"
      ca_content  = data.terraform_remote_state.root_ca.outputs.root_cert_pem
      cert_content = format("%s\n%s", lookup((data.terraform_remote_state.root_ca.outputs.signed_cert_pem), "minio", null),
        data.terraform_remote_state.root_ca.outputs.root_cert_pem
      )
      key_content = lookup((data.terraform_remote_state.root_ca.outputs.signed_key), "minio", null)
      sub_dir     = "certs"
    }
    dir = "/etc/minio"
  }
  service = {
    status  = "started"
    enabled = true
    systemd_unit_service = {
      templatefile_path = "${path.root}/minio/minio.service"
      templatefile_vars = {
        user            = "vyos"
        group           = "users"
        EnvironmentFile = "/etc/minio/minio.env"
      }
      target_path = "/usr/lib/systemd/system/minio.service"
    }
  }
}

resource "system_file" "minio_consul" {
  depends_on = [
    module.minio,
  ]
  path    = "/etc/consul.d/minio_consul.hcl"
  content = file("${path.root}/minio/minio_consul.hcl")
  user    = "vyos"
  group   = "users"
}
