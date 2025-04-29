resource "null_resource" "init" {
  connection {
    type     = "ssh"
    host     = var.prov_remote.host
    port     = var.prov_remote.port
    user     = var.prov_remote.user
    password = var.prov_remote.password
  }
  triggers = {
    dirs = "/home/podmgr/traefik-file-provider"
  }
  provisioner "remote-exec" {
    inline = [
      "mkdir ${self.triggers.dirs}"
    ]
  }
}

data "vault_kv_secret_v2" "root_ca" {
  mount = "kvv2/certs"
  name  = "root"
}

# data "terraform_remote_state" "root_ca" {
#   count   = var.podman_kube.helm.tls.tfstate == null ? 0 : 1
#   backend = var.podman_kube.helm.tls.tfstate.backend.type
#   config  = var.podman_kube.helm.tls.tfstate.backend.config
# }

# locals {
#   # cert = var.podman_kube.helm.tls.tfstate == null ? null : flatten([
#   #   for cert_name in ["pdns-auth", "traefik"] : [
#   #     for cert in data.terraform_remote_state.root_ca[0].outputs.signed_certs : cert
#   #     if cert.name == cert_name
#   #     # if cert.name == var.podman_kube.helm.tls.tfstate.cert_name
#   #   ]
#   # ])
#   cert = var.podman_kube.helm.tls.tfstate == null ? null : [
#     for cert in data.terraform_remote_state.root_ca[0].outputs.signed_certs : cert
#     if cert.name == var.podman_kube.helm.tls.tfstate.cert_name
#   ]
# }

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

module "podman_quadlet" {
  depends_on = [
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
      # custom_trigger = md5(remote_file.podman_quadlet.content)
    }
    files = [
      for file in var.podman_quadlet.files :
      {
        content = templatefile(
          file.template,
          # file.vars
          merge(
            file.vars,
            {
              ca = base64encode(data.vault_kv_secret_v2.root_ca.data["ca"]
                # join("", [
                #   local.cert[0].cert_pem,
                #   data.terraform_remote_state.root_ca[0].outputs.int_ca_pem,
                # ])
              )
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

resource "powerdns_record" "records" {
  for_each = {
    for record in var.dns_records : record.name => record
  }
  zone    = each.value.zone
  name    = each.value.name
  type    = each.value.type
  ttl     = each.value.ttl
  records = each.value.records
}

resource "remote_file" "consul_service" {
  path    = "/var/home/podmgr/consul-services/service-traefik.hcl"
  content = file("./podman-traefik/service.hcl")
}
