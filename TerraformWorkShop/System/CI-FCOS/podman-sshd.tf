# resource "system_file" "podman_sshd_yaml" {
#   path    = "/home/podmgr/.config/containers/systemd/sshd-aio.yaml"
#   content = file("./podman-sshd/aio.yaml")
# }

# resource "system_file" "podman_sshd_kube" {
#   path    = "/home/podmgr/.config/containers/systemd/podman-sshd.kube"
#   content = <<-EOT
# [Install]
# WantedBy=default.target

# [Kube]
# # Point to the yaml file in the same directory
# Yaml=sshd-aio.yaml
# # UserNS=keep-id
# EOT
# }


# resource "null_resource" "podman_sshd_service" {
#   depends_on = [
#     system_file.podman_sshd_yaml,
#     system_file.podman_sshd_kube
#   ]
#   triggers = {
#     status       = "start"
#     service_name = "podman-sshd"
#     # yaml         = data.helm_template.podman_sshd.manifest
#     kube     = system_file.podman_sshd_kube.content
#     host     = var.vm_conn.host
#     port     = var.vm_conn.port
#     user     = var.vm_conn.user
#     password = sensitive(var.vm_conn.password)
#   }
#   connection {
#     type     = "ssh"
#     host     = self.triggers.host
#     port     = self.triggers.port
#     user     = self.triggers.user
#     password = self.triggers.password
#   }
#   provisioner "remote-exec" {
#     inline = [
#       "systemctl --user daemon-reload",
#       "systemctl --user ${self.triggers.status} ${self.triggers.service_name}",
#     ]
#   }
#   provisioner "remote-exec" {
#     when = destroy
#     inline = [
#       "systemctl --user daemon-reload",
#       "systemctl --user stop ${self.triggers.service_name}",
#     ]
#   }
# }
