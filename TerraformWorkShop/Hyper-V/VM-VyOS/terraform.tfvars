hyperv = {
  host     = "127.0.0.1"
  port     = 5986
  user     = "root"
  password = "P@ssw0rd"
}

vm_name     = "VyOS-140-EPA2"
vhd_dir     = "C:\\ProgramData\\Microsoft\\Windows\\Virtual Hard Disks"
source_disk = "C:\\ProgramData\\Microsoft\\Windows\\Virtual Hard Disks\\Images\\packer-vyos140\\Virtual Hard Disks\\packer-vyos140.vhdx"
# source_disk   = "C:\\ProgramData\\Microsoft\\Windows\\Virtual Hard Disks\\output-vyos13x\\Virtual Hard Disks\\packer-vyos13x.vhdx"
data_disk_ref = "../Disk-VyOS-Data/terraform.tfstate"

network_adaptors = [
  {
    name                = "WAN"
    switch_name         = "Default Switch"
    dynamic_mac_address = false
    static_mac_address  = "0000DEADBEEF"
  },
  {
    name                = "LAN1-P1"
    switch_name         = "Internal Switch"
    dynamic_mac_address = false
    static_mac_address  = "0000FEE1600D"
  },
  # {
  #   name                = "LAN1-P2"
  #   switch_name         = "Internal Switch"
  #   dynamic_mac_address = false
  #   static_mac_address  = "0000FEE1900D"
  # },

]

enable_secure_boot   = "Off"
memory_startup_bytes = 4093640704
memory_maximum_bytes = 4093640704
memory_minimum_bytes = 1023410176

cloudinit_nocloud = [
  {
    content_source = "./cloudinit-tmpl/meta-data"
    content_vars = {
      instance_id    = "iid-VyOS_20240402"
      local_hostname = "VyOS_140_EPA2"
    }
    filename = "meta-data"
  },
  {
    content_source = "./cloudinit-tmpl/user-data-sagitta"
    content_vars = {
      null = null
    }
    filename = "user-data"
  }
]
