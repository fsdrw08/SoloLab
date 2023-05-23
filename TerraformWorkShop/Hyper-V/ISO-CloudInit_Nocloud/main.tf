locals {
  cloud_init = {
    test1 = {
      path = "./cloud-init1.iso"
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
      path = "./cloud-init2.iso"
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
    },
  }
}
module "cloudinit_nocloud_iso" {
  source = "../modules/cloudinit_nocloud_iso"

  for_each   = local.cloud_init
  cloud_init = each.value
  # cloud_init = {
  #   user-data      = <<-EOT
  #   #cloud-config
  #   timezone: Asia/Shanghai
  #   EOT
  #   network-config = <<-EOT
  #   version: 2
  #   ethernets:
  #     eth0:
  #       addresses:
  #         - 192.168.255.21/255.255.255.0
  #       gateway4: 192.168.255.1
  #       nameservers:
  #         addresses: 192.168.255.1
  #   EOT
  # }
}
