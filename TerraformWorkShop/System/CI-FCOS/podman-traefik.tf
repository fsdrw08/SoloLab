data "tls_certificate" "rootCA" {
  url          = "https://step-ca.service.consul:8443/acme/acme/directory"
  verify_chain = false
}

data "helm_template" "podman_kube_traefik" {
  name  = "traefik"
  chart = var.podman_kube_traefik.helm.chart

  set {
    name  = "traefik.customRootCA"
    value = data.tls_certificate.rootCA.certificates[0].cert_pem
  }
  values = [
    "${file(var.podman_kube_traefik.helm.values)}"
  ]
}

# output "yaml" {
#   value = data.helm_template.podman_kube_traefik.manifest
# }

resource "system_file" "podman_kube_traefik" {
  path    = "${var.podman_kube_traefik.yaml_file_dir}/traefik-aio.yaml"
  content = data.helm_template.podman_kube_traefik.manifest
}

resource "null_resource" "podman_volume_traefik" {
  triggers = {
    storage_dir = join(" ", var.podman_kube_traefik.ext_vol_dir)
    host        = var.vm_conn.host
    port        = var.vm_conn.port
    user        = var.vm_conn.user
    password    = sensitive(var.vm_conn.password)
  }
  connection {
    type     = "ssh"
    host     = self.triggers.host
    port     = self.triggers.port
    user     = self.triggers.user
    password = self.triggers.password
  }
  provisioner "remote-exec" {
    inline = [
      "for i in \"${self.triggers.storage_dir}\"; do if [ ! -d $i ]; then mkdir -p $i; fi; done"
    ]
  }
  provisioner "remote-exec" {
    when = destroy
    inline = [
      "systemctl --user daemon-reload",
    ]
  }
}

resource "system_file" "podman_quadlet_traefik" {
  depends_on = [null_resource.podman_volume_traefik]
  for_each = {
    for content in var.podman_quadlet_traefik.quadlet.file_contents : content.file_source => content
  }
  path = format("${var.podman_quadlet_traefik.quadlet.file_path_dir}/%s", basename("${each.value.file_source}"))
  content = templatefile(
    each.value.file_source,
    each.value.vars
  )
}

resource "null_resource" "podman_quadlet_traefik" {
  depends_on = [
    system_file.podman_kube_traefik,
    system_file.podman_quadlet_traefik
  ]
  triggers = {
    service_status = var.podman_quadlet_traefik.service.status
    service_name   = var.podman_quadlet_traefik.service.name
    yaml           = sha256(data.helm_template.podman_kube_traefik.manifest)
    quadlet        = join(",", (values(tomap(system_file.podman_quadlet_traefik)).*.md5sum))
    host           = var.vm_conn.host
    port           = var.vm_conn.port
    user           = var.vm_conn.user
    password       = sensitive(var.vm_conn.password)
  }
  connection {
    type     = "ssh"
    host     = self.triggers.host
    port     = self.triggers.port
    user     = self.triggers.user
    password = self.triggers.password
  }
  provisioner "remote-exec" {
    inline = [
      "systemctl --user daemon-reload",
      "systemctl --user ${self.triggers.service_status} ${self.triggers.service_name}",
    ]
  }
  provisioner "remote-exec" {
    when = destroy
    inline = [
      "systemctl --user stop ${self.triggers.service_name}",
    ]
  }
}

# resource "system_service_systemd" "podman_traefik" {
#   depends_on = [
#     system_file.podman_quadlet_traefik,
#     system_file.podman_kube_traefik
#   ]
#   name   = "traefik"
#   status = "started"
#   scope  = "user"
# }

resource "system_file" "podman_traefik_consul" {
  path    = "/etc/consul.d/traefik_consul.hcl"
  content = file("./podman-traefik/traefik_consul.hcl")
}
