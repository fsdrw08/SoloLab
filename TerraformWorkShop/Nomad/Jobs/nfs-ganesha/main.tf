resource "null_resource" "nfs_init" {
  connection {
    type     = "ssh"
    host     = var.prov_system.host
    port     = var.prov_system.port
    user     = var.prov_system.user
    password = var.prov_system.password
  }
  triggers = {
    rootless_dirs    = ""
    root_dirs        = "/var/mnt/data/nfs"
    root_chown_dirs  = "/var/mnt/data/nfs"
    root_chown_user  = "root"
    root_chown_group = "root"
  }
  provisioner "remote-exec" {
    inline = [
      templatefile("${path.root}/attachments/init.sh", {
        rootless_dirs    = split(",", self.triggers.rootless_dirs)
        root_dirs        = split(",", self.triggers.root_dirs)
        root_chown_dirs  = split(",", self.triggers.root_chown_dirs)
        root_chown_user  = self.triggers.root_chown_user
        root_chown_group = self.triggers.root_chown_group
      })
    ]
  }
}

# https://github.com/jbaikge/homelab-nomad/blob/ce67445a95aa7dd5c2e5d72b11e06b078e44e67c/nomad/traefik.tf#L2
resource "nomad_job" "nfs-ganesha" {
  depends_on = [null_resource.nfs_init]
  jobspec    = file("${path.module}/attachments/nfs-ganesha.nomad.hcl")

  hcl2 {
    allow_fs = true
    vars = {
      config = file("${path.module}/attachments/ganesha.conf")
    }
  }

  purge_on_destroy = true
}
