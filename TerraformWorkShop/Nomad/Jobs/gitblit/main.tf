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

  lifecycle {
    prevent_destroy = true
  }
}

locals {
  job_vars_map = {
    for job in var.jobs : job.path => {
      vars = job.var_sets == null ? {} : {
        for var_set in job.var_sets :
        "${var_set.name}" => var_set.value_string == null ? templatefile(var_set.value_template_path, var_set.value_template_vars) : var_set.value_string
      }
    }
  }
}

# https://github.com/jbaikge/homelab-nomad/blob/ce67445a95aa7dd5c2e5d72b11e06b078e44e67c/nomad/traefik.tf#L2
resource "nomad_job" "jobs" {
  depends_on = [nomad_csi_volume.volumes]
  for_each = {
    for job in var.jobs : job.path => job
  }

  jobspec = file(each.key)

  hcl2 {
    allow_fs = true
    vars     = local.job_vars_map[each.key] == null ? {} : local.job_vars_map[each.key].vars
  }

  purge_on_destroy = true
}

