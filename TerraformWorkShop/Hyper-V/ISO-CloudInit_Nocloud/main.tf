module "cloudinit_nocloud_iso" {
  source = "../modules/cloudinit_nocloud_iso"

  for_each = {
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
        meta-data      = <<-EOT
        instance-id: iid-infrasvc-fedora_20230516
        EOT
      }
    }
  }
  cloud_init = each.value

}
