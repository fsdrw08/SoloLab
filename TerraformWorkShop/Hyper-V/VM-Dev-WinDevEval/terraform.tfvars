hyperv = {
  host     = "127.0.0.1"
  port     = 5986
  user     = "root"
  password = "P@ssw0rd"
}

vm_name     = "WinDevEval"
vhd_dir     = "C:\\ProgramData\\Microsoft\\Windows\\Virtual Hard Disks"
source_disk = "C:\\Users\\Public\\Downloads\\VHD\\WinDevEval.vhdx"
# data_disk_ref = "../Disk-VyOS-Data/terraform.tfstate"

network_adaptors = [
  {
    name                = "WAN"
    switch_name         = "Default Switch"
    dynamic_mac_address = true
  },
]

enable_secure_boot   = "Off"
memory_startup_bytes = 4093640704
memory_maximum_bytes = 4093640704
memory_minimum_bytes = 1023410176
