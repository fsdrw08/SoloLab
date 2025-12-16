resource "nomad_dynamic_host_volume" "volumes" {
  for_each = {
    for volume in var.dynamic_host_volumes : volume.name => volume
    if var.dynamic_host_volumes != []
  }
  name       = each.value.name
  plugin_id  = each.value.plugin_id
  parameters = each.value.parameters

  dynamic "constraint" {
    for_each = each.value.constraint == null ? [] : flatten([each.value.constraint])
    content {
      attribute = constraint.value.attribute
      operator  = constraint.value.operator
      value     = constraint.value.value
    }
  }

  # https://developer.hashicorp.com/nomad/docs/other-specifications/volume/capability#parameters
  capability {
    access_mode     = each.value.capability.access_mode
    attachment_mode = "file-system"
  }
}

# https://github.com/basher83/andromeda-orchestration/blob/97df48241fefaf8288357dc2a9cd47526a17ce83/docs/implementation/nomad/storage-patterns.md#pattern-3-stateful-applications-with-csi
# https://support.hashicorp.com/hc/en-us/articles/22557185128083-Nomad-NFS-CSI-Volume
resource "nomad_csi_volume" "volumes" {
  for_each = {
    for volume in var.csi_volumes : volume.name => volume
  }
  name      = each.value.name
  plugin_id = each.value.plugin_id
  volume_id = each.value.volume_id

  dynamic "capability" {
    for_each = each.value.capabilities
    content {
      access_mode     = lookup(capability.value, "access_mode", null)
      attachment_mode = lookup(capability.value, "attachment_mode", null)
    }
  }

  capacity_min = each.value.capacity_min
  capacity_max = each.value.capacity_max

  parameters = each.value.parameters
  mount_options {
    fs_type     = each.value.mount_options.fs_type
    mount_flags = each.value.mount_options.mount_flags
  }
}
