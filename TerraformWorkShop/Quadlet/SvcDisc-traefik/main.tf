resource "remote_file" "http_socket" {
  content = templatefile(
    "./podman-traefik/http.socket",
    {
      name = "traefik-container"
    }
  )
  path = "/home/podmgr/.config/systemd/user/http.socket"
}

resource "remote_file" "https_socket" {
  content = templatefile(
    "./podman-traefik/https.socket",
    {
      name = "traefik-container"
    }
  )
  path = "/home/podmgr/.config/systemd/user/https.socket"
}

resource "null_resource" "service_stop" {
  depends_on = [
    remote_file.http_socket,
    remote_file.https_socket
  ]
  triggers = {
    service_name = "http.socket https.socket"
    host         = var.prov_remote.host
    port         = var.prov_remote.port
    user         = var.prov_remote.user
    password     = sensitive(var.prov_remote.password)
  }
  connection {
    type     = "ssh"
    host     = self.triggers.host
    port     = self.triggers.port
    user     = self.triggers.user
    password = self.triggers.password
  }
  provisioner "remote-exec" {
    when = destroy
    inline = [
      "systemctl --user stop ${self.triggers.service_name}",
    ]
  }
}

data "vault_kv_secret_v2" "cert" {
  count = var.podman_kube.helm.secrets_value_sets == null ? 0 : 1
  mount = var.podman_kube.helm.secrets_value_sets.value_ref.vault_kvv2.mount
  name  = var.podman_kube.helm.secrets_value_sets.value_ref.vault_kvv2.name
}

module "podman_quadlet" {
  depends_on = [
    # remote_file.podman_quadlet,
    remote_file.http_socket,
    remote_file.https_socket,
    null_resource.service_stop
  ]
  source  = "../../modules/system-systemd_quadlet"
  vm_conn = var.prov_remote
  podman_quadlet = {
    service = {
      name   = var.podman_quadlet.service.name
      status = var.podman_quadlet.service.status
      # custom_trigger = md5(remote_file.podman_kube.content)
    }
    files = [
      for file in var.podman_quadlet.files :
      {
        content = templatefile(
          file.template,
          merge(
            file.vars,
            {
              # ca   = data.vault_kv_secret_v2.cert[0].data["ca"]
              # cert = data.vault_kv_secret_v2.cert[0].data["cert"]
              # key  = data.vault_kv_secret_v2.cert[0].data["private_key"]
              ca = base64encode(data.vault_kv_secret_v2.cert[0].data["ca"])
              # cert = base64encode(data.vault_kv_secret_v2.cert[0].data["cert"])
              # key  = base64encode(data.vault_kv_secret_v2.cert[0].data["private_key"])
            }
          )
        )
        path = join("/", [
          file.dir,
          basename("${file.template}")
        ])
      }
    ]
  }
}

resource "powerdns_record" "record" {
  zone    = var.dns_record.zone
  name    = var.dns_record.name
  type    = var.dns_record.type
  ttl     = var.dns_record.ttl
  records = var.dns_record.records
}

resource "remote_file" "consul_service" {
  path    = "/var/home/podmgr/consul-services/service-traefik.hcl"
  content = file("./podman-traefik/service.hcl")
}
