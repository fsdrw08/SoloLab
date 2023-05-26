locals {
  cloud_init = {
    test1 = {
      path = "cloud-init1.iso"
      content = {
        # https://cloudinit.readthedocs.io/en/latest/reference/datasources/nocloud.html#configuration-methods
        # https://developer.hashicorp.com/terraform/language/expressions/strings#indented-heredocs
        user-data      = <<-EOT
        #cloud-config
        timezone: Asia/Shanghai
        EOT
        network-config = <<-EOT
        version: 2
        ethernets:
          eth0:
            dhcp4: true
        EOT
      }
    }
    test2 = {
      path = "cloud-init2.iso"
      content = {
        # https://cloudinit.readthedocs.io/en/latest/reference/datasources/nocloud.html#configuration-methods
        # https://developer.hashicorp.com/terraform/language/expressions/strings#indented-heredocs
        user-data      = <<-EOT
        #cloud-config
        timezone: Asia/Shanghai
        EOT
        network-config = <<-EOT
        version: 2
        ethernets:
          eth0:
            dhcp4: true123
        EOT
      }
    },
  }

  vhd_dir = "C:\\ProgramData\\Microsoft\\Windows\\Virtual Hard Disks"
}

module "cloudinit_nocloud_iso" {
  source = "../modules/cloudinit_nocloud_iso"

  for_each   = local.cloud_init
  cloud_init = each.value

}

resource "null_resource" "remote" {
  depends_on = [module.cloudinit_nocloud_iso]
  for_each   = local.cloud_init

  triggers = {
    # https://discuss.hashicorp.com/t/terraform-null-resources-does-not-detect-changes-i-have-to-manually-do-taint-to-recreate-it/23443/3
    manifest_sha1 = sha1(jsonencode(local.cloud_init))
    vhd_dir       = local.vhd_dir
    # https://github.com/Azure/caf-terraform-landingzones/blob/a54831d73c394be88508717677ed75ea9c0c535b/caf_solution/add-ons/terraform_cloud/terraform_cloud.tf#L2
    isoName  = lookup(each.value, "path")
    host     = var.host
    user     = var.user
    password = sensitive(var.password)
  }

  connection {
    type     = "winrm"
    host     = self.triggers.host
    user     = self.triggers.user
    password = self.triggers.password
    use_ntlm = true
    https    = true
    insecure = true
    timeout  = "20s"
  }
  # copy to remote
  provisioner "file" {
    source = each.value.path
    # destination = "C:\\ProgramData\\Microsoft\\Windows\\Virtual Hard Disks\\${each.key}\\cloud-init.iso"
    destination = join("/", ["${self.triggers.vhd_dir}", "${each.key}\\${self.triggers.isoName}"])
  }

  # for destroy
  provisioner "remote-exec" {
    when = destroy
    inline = [<<-EOT
      Powershell -Command "$cloudinit_iso=(Join-Path -Path '${self.triggers.vhd_dir}' -ChildPath '${each.key}\${self.triggers.isoName}'); if (Test-Path $cloudinit_iso) { Remove-Item $cloudinit_iso }"
    EOT
    ]
  }
}
