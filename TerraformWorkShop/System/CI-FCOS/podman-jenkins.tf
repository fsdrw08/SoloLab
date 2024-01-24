data "helm_template" "podman_kube_jenkins" {
  name  = "jenkins"
  chart = var.podman_kube_jenkins.helm.chart

  values = [
    "${file(var.podman_kube_jenkins.helm.values)}"
  ]
}

resource "system_file" "podman_kube_jenkins" {
  path    = "${var.podman_kube_jenkins.yaml_file_dir}/jenkins-aio.yaml"
  content = data.helm_template.podman_kube_jenkins.manifest
}

resource "null_resource" "podman_volume_jenkins" {
  triggers = {
    storage_dir = join(" ", var.podman_kube_jenkins.ext_vol_dir)
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

# # https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html#kube-units-kube
resource "system_file" "podman_quadlet_jenkins" {
  depends_on = [null_resource.podman_volume_jenkins]
  for_each = {
    for content in var.podman_quadlet_jenkins.quadlet.file_contents : content.file_source => content
  }
  path = format("${var.podman_quadlet_jenkins.quadlet.file_path_dir}/%s", basename("${each.value.file_source}"))
  content = templatefile(
    each.value.file_source,
    each.value.vars
  )
}

resource "null_resource" "podman_quadlet_jenkins" {
  depends_on = [
    system_file.podman_kube_jenkins,
    system_file.podman_quadlet_jenkins
  ]
  triggers = {
    service_status = var.podman_quadlet_jenkins.service.status
    service_name   = var.podman_quadlet_jenkins.service.name
    yaml           = sha256(data.helm_template.podman_kube_jenkins.manifest)
    quadlet        = join(",", (values(tomap(system_file.podman_quadlet_jenkins)).*.md5sum))
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

# # resource "system_service_systemd" "podman_jenkins" {
# #   depends_on = [
# #     system_file.podman_jenkins_kube,
# #     system_file.podman_jenkins_yaml
# #   ]
# #   name   = "jenkins"
# #   status = "started"
# #   scope  = "user"
# # }

resource "system_file" "podman_jenkins_consul" {
  path    = "/etc/consul.d/jenkins_consul.hcl"
  content = file("./podman-jenkins/jenkins_consul.hcl")
}
