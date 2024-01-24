resource "system_file" "podman_kube_sshd" {
  path    = "/home/podmgr/.config/containers/systemd/sshd-aio.yaml"
  content = file("./podman-sshd/aio.yaml")
}

resource "null_resource" "podman_other_sshd" {
  triggers = {
    host     = var.vm_conn.host
    port     = var.vm_conn.port
    user     = var.vm_conn.user
    password = sensitive(var.vm_conn.password)
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
      "systemctl --user daemon-reload",
    ]
  }
}

resource "system_file" "podman_quadlet_sshd" {
  depends_on = [null_resource.podman_other_sshd]
  path       = "/home/podmgr/.config/containers/systemd/podman-sshd.kube"
  content    = <<-EOT
[Install]
WantedBy=default.target

[Kube]
# Point to the yaml file in the same directory
Yaml=sshd-aio.yaml
# UserNS=keep-id
EOT
}


resource "null_resource" "podman_quadlet_sshd" {
  depends_on = [
    system_file.podman_kube_sshd,
    system_file.podman_quadlet_sshd
  ]
  triggers = {
    service_status = "start"
    service_name   = "podman-sshd"
    yaml           = system_file.podman_kube_sshd.md5sum
    quadlet        = system_file.podman_quadlet_sshd.md5sum
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
