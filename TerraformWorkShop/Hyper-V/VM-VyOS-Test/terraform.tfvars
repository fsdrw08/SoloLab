hyperv = {
  host     = "127.0.0.1"
  port     = 5986
  user     = "root"
  password = "P@ssw0rd"
}

vm_name     = "VyOS-150-test"
vhd_dir     = "C:\\ProgramData\\Microsoft\\Windows\\Virtual Hard Disks"
source_disk = "C:\\ProgramData\\Microsoft\\Windows\\Virtual Hard Disks\\Images\\packer-vyos150\\Virtual Hard Disks\\packer-vyos150.vhdx"
# source_disk   = "C:\\ProgramData\\Microsoft\\Windows\\Virtual Hard Disks\\output-vyos13x\\Virtual Hard Disks\\packer-vyos13x.vhdx"
data_disk_ref = "../Disk-VyOS-Data/terraform.tfstate"

network_adaptors = [
  # {
  #   name                = "WAN"
  #   switch_name         = "Default Switch"
  #   dynamic_mac_address = false
  #   static_mac_address  = "0000DEADBEEF"
  # },
  {
    name                = "LAN1-P1"
    switch_name         = "Internal Switch"
    dynamic_mac_address = true
    # static_mac_address  = "0000FEE1600D"
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

cloudinit_nocloud = [
  {
    content_source = "./cloudinit-tmpl/meta-data"
    content_vars = {
      instance_id    = "iid-VyOS_20240402"
      local_hostname = "VyOS_150_dev"
    }
    filename = "meta-data"
  },
  {
    content_source = "./cloudinit-tmpl/user-data-sagitta"
    content_vars = {
      null                = null
      dhcp_subnet_range   = "192.168.255.0/24"
      dhcp_subnet_start   = "192.168.255.100"
      dhcp_subnet_stop    = "192.168.255.200"
      dhcp_name_server    = "192.168.255.1"
      dhcp_default_router = "192.168.255.1"
      dhcp_domain_name    = "sololab"
      eth0_address        = "dhcp"
      eth0_desc           = "MGMT"
      hostname            = "vyos-test"
      user_name           = "vyos"
      user_password       = "vyos"
      user_public_key     = "AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ=="
      user_public_type    = "ssh-rsa"
    }
    filename = "user-data"
  }
]
