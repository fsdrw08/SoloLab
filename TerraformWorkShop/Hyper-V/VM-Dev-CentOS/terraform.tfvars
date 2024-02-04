hyperv = {
  host     = "127.0.0.1"
  port     = 5986
  user     = "root"
  password = "P@ssw0rd"
}

vm_name  = "Dev-CentOS"
vm_count = 1
# vhd_dir     = "C:\\ProgramData\\Microsoft\\Windows\\Virtual Hard Disks"
vhd_dir     = "C:\\ProgramData\\Microsoft\\Windows\\Virtual Hard Disks"
source_disk = "C:\\ProgramData\\Microsoft\\Windows\\Virtual Hard Disks\\Images\\Virtual Hard Disks\\packer-centos-stream-9-g2.vhdx"
network_adaptors = [
  {
    name        = "Internal Switch"
    switch_name = "Internal Switch"
  }
]
enable_secure_boot   = "On"
memory_maximum_bytes = 8191475712
memory_minimum_bytes = 2147483648
memory_startup_bytes = 2147483648

cloudinit = {
  meta_data = {
    file_source = "./cloudinit-tmpl/meta-data"
    vars = {
      instance_id    = "iid-dev-CentOS_202401"
      local_hostname = "Dev-CentOS"
      count          = "1"
    }
  }
  user_data = {
    file_source = "./cloudinit-tmpl/user-data"
    vars = {

    }
  }
  network_config = {
    file_source = "./cloudinit-tmpl/network-config"
    vars = {
      ip_count = ["1"]
      ip_addr_list = [
        "192.168.255.14/24",
        "192.168.255.15/24",
      ]
      gateway4 = ["192.168.255.1"]
      nameservers = [
        "192.168.255.1"
      ]
    }
  }
}

