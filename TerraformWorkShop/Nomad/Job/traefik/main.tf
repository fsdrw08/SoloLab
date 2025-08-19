# https://github.com/jbaikge/homelab-nomad/blob/ce67445a95aa7dd5c2e5d72b11e06b078e44e67c/nomad/traefik.tf#L2
resource "nomad_job" "traefik" {
  jobspec = file("${path.module}/attachments/traefik.nomad.hcl")

  hcl2 {
    vars = {
      static_config = templatefile("${path.module}/attachments/static.traefik.yml", {
        domain = "hardwood.cloud"
      })
      dynamic_config = file("${path.module}/attachments/dynamic.traefik.yml")
    }
  }
}
