hyperv = {
  host     = "127.0.0.1"
  port     = 5986
  user     = "root"
  password = "P@ssw0rd"
}


vm_name       = "Dev-Fedora"
vhd_dir       = "C:\\ProgramData\\Microsoft\\Windows\\Virtual Hard Disks"
source_disk   = "C:\\ProgramData\\Microsoft\\Windows\\Virtual Hard Disks\\Images\\packer-fedora39\\Virtual Hard Disks\\packer-fedora39-g2.vhdx"
data_disk_ref = "../Disk-Dev-Fedora-Data/terraform.tfstate"

network_adaptors = [
  {
    name                = "LAN"
    switch_name         = "Internal Switch"
    dynamic_mac_address = true
  },
]

enable_secure_boot = "On"

memory_startup_bytes = 2147483648
memory_maximum_bytes = 8191475712
memory_minimum_bytes = 2147483648

cloudinit_nocloud = [
  {
    content_source = "./cloudinit-tmpl/meta-data"
    content_vars = {
      instance_id    = "iid-dev-Fedora_20240420"
      local_hostname = "Dev-Fedora"
    }
    filename = "meta-data"
  },
  {
    content_source = "./cloudinit-tmpl/user-data-39"
    content_vars = {
      null = null
    }
    filename = "user-data"
  },
  {
    content_source = "./cloudinit-tmpl/network-config"
    content_vars = {
      "interface"    = "eth0"
      "addresses4"   = "192.168.255.20/24"
      "gateway4"     = "192.168.255.1"
      "ns_addresses" = "192.168.255.1"
    }
    filename = "network-config"
  }
]
