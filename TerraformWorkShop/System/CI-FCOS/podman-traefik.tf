data "tls_certificate" "rootCA" {
  url          = "https://step-ca.service.consul:8443/acme/acme/directory"
  verify_chain = false
}

data "helm_template" "podman_traefik" {
  name  = "traefik"
  chart = "${path.module}/../../../HelmWorkShop/helm-charts/charts/traefik"

  set {
    name  = "traefik.customRootCA"
    value = data.tls_certificate.rootCA.certificates[0].cert_pem
  }
  values = [
    "${file("./podman-traefik/values-sololab-ci.yaml")}"
  ]
}

# output "yaml" {
#   value = data.helm_template.podman_traefik.manifest
# }

resource "system_file" "podman_traefik_yaml" {
  path    = "/home/podmgr/.config/containers/systemd/traefik-aio.yaml"
  content = data.helm_template.podman_traefik.manifest
}

resource "system_file" "podman_traefik_kube" {
  path    = "/home/podmgr/.config/containers/systemd/traefik.kube"
  content = <<-EOT
[Unit]
Description="Traefik Proxy"
Documentation=https://docs.traefik.io
Requires=var-mnt-data.mount

[Install]
WantedBy=default.target

[Kube]
# Point to the yaml file in the same directory
Yaml=traefik-aio.yaml
EOT
}

# resource "system_service_systemd" "podman_traefik" {
#   depends_on = [
#     system_file.podman_traefik_kube,
#     system_file.podman_traefik_yaml
#   ]
#   name   = "traefik"
#   status = "started"
#   scope  = "user"
# }
