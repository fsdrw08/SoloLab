module "cloudinit_nocloud_iso" {
  source = "../modules/cloudinit_nocloud_iso"

  cloud_init = {
    user-data      = <<-EOT
    #cloud-config
    timezone: Asia/Shanghai
    EOT
    network-config = <<-EOT
    version: 2
    ethernets:
      eth0:
        addresses:
          - 192.168.255.21/255.255.255.0
        gateway4: 192.168.255.1
        nameservers:
          addresses: 192.168.255.1
    EOT
  }
}
