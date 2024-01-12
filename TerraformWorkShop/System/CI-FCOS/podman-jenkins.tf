# data "helm_template" "podman_jenkins" {
#   name  = "jenkins"
#   chart = "${path.module}/../../../HelmWorkShop/helm-charts/charts/jenkins"

#   values = [
#     "${file("${path.module}/../../../HelmWorkShop/helm-charts/charts/jenkins/values-sololab-ci.yaml")}"
#   ]
# }

# resource "system_file" "podman_jenkins_yaml" {
#   path    = "/home/podmgr/.config/containers/systemd/jenkins-aio.yaml"
#   content = data.helm_template.podman_jenkins.manifest
# }

# resource "system_file" "podman_jenkins_kube" {
#   path    = "/home/podmgr/.config/containers/systemd/jenkins.kube"
#   content = <<-EOT
# [Install]
# WantedBy=default.target

# [Kube]
# # Point to the yaml file in the same directory
# Yaml=jenkins-aio.yaml
# # Use the host network
# Network=host
# UserNS=keep-id:uid=100,gid=1000
# EOT
# }
