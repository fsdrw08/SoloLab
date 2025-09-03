# https://github.com/jbaikge/homelab-nomad/blob/ce67445a95aa7dd5c2e5d72b11e06b078e44e67c/nomad/traefik.tf#L2
resource "nomad_job" "traefik" {
  jobspec = file("${path.module}/attachments/nfs-controller.nomad.hcl")

  hcl2 {
    allow_fs = true
    # vars = {
    #   install_config = file("${path.module}/attachments/install.traefik.yml")
    #   routing_config = file("${path.module}/attachments/routing.traefik.yml")
    # }
  }

  purge_on_destroy = true
}

