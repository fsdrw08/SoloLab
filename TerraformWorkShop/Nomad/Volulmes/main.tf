resource "nomad_dynamic_host_volume" "volumes" {
  for_each = {
    for volume in var.dynamic_host_volumes : volume.name => volume
  }
  name      = each.value.name
  plugin_id = "mkdir"

  # https://developer.hashicorp.com/nomad/docs/other-specifications/volume/capability#parameters
  capability {
    access_mode     = each.value.capability.access_mode
    attachment_mode = "file-system"
  }
}
