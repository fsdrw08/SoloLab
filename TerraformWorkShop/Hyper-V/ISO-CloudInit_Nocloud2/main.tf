data "terraform_remote_state" "root_ca" {
  backend = "local"
  config = {
    path = "../../TLS/RootCA/terraform.tfstate"
  }
}

module "cloudinit_nocloud_iso" {
  source = "../modules/cloudinit_nocloud_iso2"
  cloudinit_config = {
    isoName = "cloud-init-${var.vm_name}.iso"
    part = [
      for content in var.cloudinit_nocloud : {
        content = templatefile(content.content_source, merge(content.content_vars,
          {
            ca_cert = join("",
              slice(
                split("\n", data.terraform_remote_state.root_ca.outputs.int_ca_pem),
                1,
                length(
                  split("\n", data.terraform_remote_state.root_ca.outputs.int_ca_pem)
                ) - 2
              )
            )
            root_ca = data.terraform_remote_state.root_ca.outputs.root_cert_pem
            vyos_cert = join("",
              slice(
                split("\n", lookup(data.terraform_remote_state.root_ca.outputs.signed_cert_pem, "vyos", null)),
                1,
                length(
                  split("\n", lookup(data.terraform_remote_state.root_ca.outputs.signed_cert_pem, "vyos", null))
                ) - 2
              )
            )
            vyos_key = join("",
              slice(
                split("\n", lookup(data.terraform_remote_state.root_ca.outputs.signed_key_pkcs8, "vyos", null)),
                1,
                length(
                  split("\n", lookup(data.terraform_remote_state.root_ca.outputs.signed_key_pkcs8, "vyos", null))
                ) - 2
              )
            )
            # haproxy_cfg = file("${path.module}/cloudinit-tmpl/haproxy.cfg.j2")
          }
        ))
        filename = content.filename
      }
    ]
  }
}
# module "cloudinit_nocloud_iso" {
#   source = "../modules/cloudinit_nocloud_iso2"
#   count  = local.count
#   cloudinit_config = {
#     isoName = local.count <= 1 ? "cloud-init.iso" : "cloud-init${count.index + 1}.iso"
#     part = [
#       {
#         filename = "user-data"
#         content  = <<-EOT
#         #cloud-config
#         timezone: Asia/Shanghai
#         EOT
#       },
#       {
#         filename = "network-config"
#         content  = <<-EOT
#         version: 2
#         ethernets:
#           eth0:
#             addresses:
#               - 192.168.255.1${count.index + 1}/255.255.255.0
#             gateway4: 192.168.255.1
#             nameservers:
#               addresses: 192.168.255.1
#         EOT
#       }
#     ]
#   }
# }

# resource "null_resource" "remote" {
#   depends_on = [module.cloudinit_nocloud_iso]
#   count      = local.count
#   triggers = {
#     # https://discuss.hashicorp.com/t/terraform-null-resources-does-not-detect-changes-i-have-to-manually-do-taint-to-recreate-it/23443/3
#     manifest_sha1 = sha1(jsonencode(module.cloudinit_nocloud_iso[count.index].cloudinit_config))
#     vhd_dir       = local.vhd_dir
#     vm_name       = local.count <= 1 ? "${local.vm_name}" : "${local.vm_name}${count.index + 1}"
#     # https://github.com/Azure/caf-terraform-landingzones/blob/a54831d73c394be88508717677ed75ea9c0c535b/caf_solution/add-ons/terraform_cloud/terraform_cloud.tf#L2
#     isoName  = module.cloudinit_nocloud_iso[count.index].isoName
#     host     = var.host
#     user     = var.user
#     password = sensitive(var.password)
#   }

#   connection {
#     type     = "winrm"
#     host     = self.triggers.host
#     user     = self.triggers.user
#     password = self.triggers.password
#     use_ntlm = true
#     https    = true
#     insecure = true
#     timeout  = "20s"
#   }
#   # copy to remote
#   provisioner "file" {
#     source = module.cloudinit_nocloud_iso[count.index].isoName
#     # destination = "C:\\ProgramData\\Microsoft\\Windows\\Virtual Hard Disks\\${each.key}\\cloud-init.iso"
#     destination = join("/", ["${self.triggers.vhd_dir}", "${self.triggers.vm_name}\\${self.triggers.isoName}"])
#   }

#   # for destroy
#   provisioner "remote-exec" {
#     when = destroy
#     inline = [<<-EOT
#       Powershell -Command "$cloudinit_iso=(Join-Path -Path '${self.triggers.vhd_dir}' -ChildPath '${self.triggers.vm_name}\${self.triggers.isoName}'); if (Test-Path $cloudinit_iso) { Remove-Item $cloudinit_iso }"
#     EOT
#     ]
#   }
# }
