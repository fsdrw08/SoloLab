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

resource "minio_s3_bucket" "bucket" {
  bucket = "quadlet"
  acl    = "public"
}

resource "minio_s3_object" "SvcDisc_Traefik_kube" {
  bucket_name  = minio_s3_bucket.bucket.bucket
  object_name  = "SvcDisc/traefik.kube"
  content      = data.helm_template.podman_traefik.manifest
  content_type = "text/plain"
}

resource "minio_s3_object" "SvcDisc_Consul_kube" {
  bucket_name  = minio_s3_bucket.bucket.bucket
  object_name  = "SvcDisc/consul.kube"
  content      = data.helm_template.podman_consul.manifest
  content_type = "text/plain"

}
