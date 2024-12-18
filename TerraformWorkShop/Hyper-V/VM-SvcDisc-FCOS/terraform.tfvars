hyperv = {
  host     = "127.0.0.1"
  port     = 5986
  user     = "root"
  password = "P@ssw0rd"
}

vm_name = "SvcDisc-FCOS"
vhd_dir = "C:\\ProgramData\\Microsoft\\Windows\\Virtual Hard Disks"
# https://fedoraproject.org/coreos/download?stream=stable
source_disk   = "C:\\ProgramData\\Microsoft\\Windows\\Virtual Hard Disks\\Images\\fcos\\fedora-coreos-hyperv.x86_64.vhdx"
data_disk_ref = "../Disk-SvcDisc-FCOS-Data/terraform.tfstate"
# data_disk_path = "C:\\ProgramData\\Microsoft\\Windows\\Virtual Hard Disks\\Data_Disk\\SvcDisc-FCOS-Data.vhdx"
network_adaptors = [
  {
    name                = "LAN1"
    switch_name         = "Internal Switch"
    dynamic_mac_address = true
    # static_mac_address  = "0000FEE1600D"
  },
]

enable_secure_boot   = "On"
memory_startup_bytes = 2046820352
memory_maximum_bytes = 2046820352
memory_minimum_bytes = 1023410176

fcos_timezone = "Asia/Shanghai"
