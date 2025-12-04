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

