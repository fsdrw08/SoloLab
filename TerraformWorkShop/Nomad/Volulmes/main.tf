resource "nomad_dynamic_host_volume" "volumes" {
  for_each = {
    for volume in var.volumes.dynamic_host_volumes : volume.name => volume
    if var.volumes.dynamic_host_volumes != []
  }
  name      = each.value.name
  plugin_id = "mkdir"

  # https://developer.hashicorp.com/nomad/docs/other-specifications/volume/capability#parameters
  capability {
    access_mode     = each.value.capability.access_mode
    attachment_mode = "file-system"
  }
}

# https://github.com/livioribeiro/nomad-lxd-terraform/blob/0c792716c9824c4c59de349d27b6aa1d1c16b09d/modules/nomad_jobs/jobs/rocketduck-nfs/controller.nomad.hcl

# https://support.hashicorp.com/hc/en-us/articles/22557185128083-Nomad-NFS-CSI-Volume
resource "nomad_csi_volume" "volumes" {
  name      = "nfs-day1-volume"
  plugin_id = "nfs"
  volume_id = "traefik"

  capability {
    access_mode     = "multi-node-multi-writer"
    attachment_mode = "file-system"
  }

  capability {
    access_mode     = "single-node-writer"
    attachment_mode = "file-system"
  }

  context = {
    server = "192.168.255.20"
    share  = "/traefik/acme"
  }

  mount_options {
    fs_type = "nfs"
  }
}
