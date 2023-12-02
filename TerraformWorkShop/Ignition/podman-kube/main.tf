data "helm_template" "podman_traefik" {
  name  = "traefik"
  chart = "${path.module}/../../../HelmWorkShop/helm-charts/charts/traefik"

  values = [
    "${file("${path.module}/../../../HelmWorkShop/helm-charts/charts/traefik/values-sololab.yaml")}"
  ]
}

data "helm_template" "podman_consul" {
  name  = "consul"
  chart = "${path.module}/../../../HelmWorkShop/helm-charts/charts/consul"

  values = [
    "${file("${path.module}/../../../HelmWorkShop/helm-charts/charts/consul/values-sololab-server.yaml")}"
  ]
}

resource "consul_keys" "podman_traefik" {
  key {
    path  = "ignition/kube/podman-traefik"
    value = data.helm_template.podman_consul.manifest
  }
}

resource "consul_keys" "podman_consul" {
  key {
    path  = "ignition/kube/podman-consul-server"
    value = data.helm_template.podman_consul.manifest
  }
}
