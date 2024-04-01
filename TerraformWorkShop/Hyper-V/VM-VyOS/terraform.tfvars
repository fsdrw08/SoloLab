hyperv = {
  host     = "127.0.0.1"
  port     = 5986
  user     = "root"
  password = "P@ssw0rd"
}

vm_conn = {
  host     = "192.168.255.1"
  port     = 22
  user     = "vyos"
  password = "vyos"
}

vm_name     = "VyOS-140-EPA2"
source_disk = "C:\\ProgramData\\Microsoft\\Windows\\Virtual Hard Disks\\Images\\Virtual Hard Disks\\packer-vyos140.vhdx"
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
memory_startup_bytes = 2046820352
memory_maximum_bytes = 2046820352
memory_minimum_bytes = 1023410176

