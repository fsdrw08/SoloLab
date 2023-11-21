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
    "${file("${path.module}/../../../HelmWorkShop/helm-charts/charts/consul/values-sololab.yaml")}"
  ]
}

resource "consul_keys" "quadlet_kube" {

}
