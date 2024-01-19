data "helm_template" "podman_jenkins" {
  name  = "jenkins"
  chart = "${path.module}/../../../HelmWorkShop/helm-charts/charts/jenkins-server"

  values = [
    "${file("./podman-jenkins/values-sololab-ci.yaml")}"
  ]
}

resource "system_file" "podman_jenkins_yaml" {
  path    = "/home/podmgr/.config/containers/systemd/jenkins-aio.yaml"
  content = data.helm_template.podman_jenkins.manifest
}

# https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html#kube-units-kube
resource "system_file" "podman_jenkins_kube" {
  path    = "/home/podmgr/.config/containers/systemd/jenkins.kube"
  content = <<-EOT
[Install]
WantedBy=default.target

[Kube]
# Point to the yaml file in the same directory
Yaml=jenkins-aio.yaml
# user namespace mapping, need to point out the uid and gid which using in container
# should able to use annotation io.podman.annotations.userns: keep-id:uid=1000,gid=1000 
# instead in podman v4.9+ (maybe)
UserNS=keep-id:uid=1000,gid=1000
EOT
}

resource "null_resource" "podman_jenkins_service" {
  depends_on = [
    system_file.podman_jenkins_yaml,
    system_file.podman_jenkins_kube
  ]
  triggers = {
    status       = "start"
    service_name = "jenkins"
    # yaml         = data.helm_template.podman_jenkins.manifest
    kube     = system_file.podman_jenkins_kube.content
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
    inline = [
      "systemctl --user daemon-reload",
      "systemctl --user ${self.triggers.status} ${self.triggers.service_name}",
    ]
  }
  provisioner "remote-exec" {
    when = destroy
    inline = [
      "systemctl --user daemon-reload",
      "systemctl --user stop ${self.triggers.service_name}",
    ]
  }
}

# resource "system_service_systemd" "podman_jenkins" {
#   depends_on = [
#     system_file.podman_jenkins_kube,
#     system_file.podman_jenkins_yaml
#   ]
#   name   = "jenkins"
#   status = "started"
#   scope  = "user"
# }

resource "system_file" "podman_jenkins_consul" {
  path    = "/etc/consul.d/jenkins_consul.hcl"
  content = file("./podman-jenkins/jenkins_consul.hcl")
}
