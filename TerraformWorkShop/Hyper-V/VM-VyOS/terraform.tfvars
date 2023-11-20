hyperv_host     = "127.0.0.1"
hyperv_port     = 5986
hyperv_user     = "root"
hyperv_password = "P@ssw0rd"

vm_name       = "VyOS-LTS-134"
source_disk   = "C:\\ProgramData\\Microsoft\\Windows\\Virtual Hard Disks\\Images\\Virtual Hard Disks\\packer-vyos134.vhdx"
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
