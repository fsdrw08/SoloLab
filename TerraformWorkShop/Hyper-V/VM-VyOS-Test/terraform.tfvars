host          = "127.0.0.1"
user          = "root"
password      = "P@ssw0rd"
vm_name       = "VyOS-LTS-133"
source_disk   = "C:\\ProgramData\\Microsoft\\Windows\\Virtual Hard Disks\\Images\\Virtual Hard Disks\\packer-vyos133.vhdx"
data_disk_ref = "../Disk-VyOS-Data/terraform.tfstate"
network_adaptors = [
  {
    name        = "Default Switch"
    switch_name = "Default Switch"
  },
  {
    name        = "Internal Switch"
    switch_name = "Internal Switch"
  },

]
enable_secure_boot   = "Off"
memory_startup_bytes = 1023410176
memory_maximum_bytes = 2147483648
memory_minimum_bytes = 1023410176
