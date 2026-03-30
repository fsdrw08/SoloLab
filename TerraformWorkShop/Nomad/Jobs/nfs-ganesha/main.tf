# resource "null_resource" "nfs_init" {
#   connection {
#     type     = "ssh"
#     host     = var.prov_system.host
#     port     = var.prov_system.port
#     user     = var.prov_system.user
#     password = var.prov_system.password
#   }
#   triggers = {
#     rootless_dirs    = ""
#     root_dirs        = "/var/mnt/data/nfs"
#     root_chown_dirs  = "/var/mnt/data/nfs"
#     root_chown_user  = "root"
#     root_chown_group = "root"
#   }
#   provisioner "remote-exec" {
#     inline = [
#       templatefile("${path.root}/attachments/init.sh", {
#         rootless_dirs    = split(",", self.triggers.rootless_dirs)
#         root_dirs        = split(",", self.triggers.root_dirs)
#         root_chown_dirs  = split(",", self.triggers.root_chown_dirs)
#         root_chown_user  = self.triggers.root_chown_user
#         root_chown_group = self.triggers.root_chown_group
#       })
#     ]
#   }
# }

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
