data "cloudinit_config" "cloudinit" {
  count = 3
  part {
    filename = "user-data"
    content  = <<-EOT
    #cloud-config
    timezone: Asia/Shanghai
    EOT
  }

  part {
    filename = "user-data"
    content  = <<-EOT
    version: 2
    ethernets:
      eth0:
        addresses:
          - 192.168.255.1${count.index + 1}/255.255.255.0
        gateway4: 192.168.255.1
        nameservers:
          addresses: 192.168.255.1
    EOT
  }
}

locals {
  cloudinit = data.cloudinit_config.cloudinit
}

module "cloudinit_nocloud_iso" {
  source = "../modules/cloudinit_nocloud_iso2"
  count  = 3
  cloudinit_config = {
    isoPath = "cloud-init${count.index}.iso"
    part = [
      {
        filename = "user-data"
        content  = <<-EOT
        #cloud-config
        timezone: Asia/Shanghai
        EOT
      },
      {
        filename = "user-data"
        content  = <<-EOT
        version: 2
        ethernets:
          eth0:
            addresses:
              - 192.168.255.1${count.index + 1}/255.255.255.0
            gateway4: 192.168.255.1
            nameservers:
              addresses: 192.168.255.1
        EOT
      }
    ]
  }
}
