# https://github.com/jbaikge/homelab-nomad/blob/ce67445a95aa7dd5c2e5d72b11e06b078e44e67c/nomad/traefik.tf#L2
resource "nomad_job" "job" {
  jobspec = file("${path.module}/attachments/nfs-nodes.nomad.hcl")

  hcl2 {
    allow_fs = true
  }

  purge_on_destroy = true
}

