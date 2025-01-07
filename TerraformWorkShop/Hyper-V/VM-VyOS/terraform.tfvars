hyperv = {
  host     = "127.0.0.1"
  port     = 5986
  user     = "root"
  password = "P@ssw0rd"
}

vm = {
  count     = 1
  base_name = "VyOS"
  vhd = {
    dir = "C:\\ProgramData\\Microsoft\\Windows\\Virtual Hard Disks"
    # https://fedoraproject.org/coreos/download?stream=stable
    source = "C:\\ProgramData\\Microsoft\\Windows\\Virtual Hard Disks\\Images\\packer-vyos15x\\Virtual Hard Disks\\packer-vyos15x.vhdx"
    # source = "C:\\ProgramData\\Microsoft\\Windows\\Virtual Hard Disks\\Images\\packer-vyos14x\\Virtual Hard Disks\\packer-vyos14x.vhdx"
    # source = "C:\\ProgramData\\Microsoft\\Windows\\Virtual Hard Disks\\Images\\packer-vyos13x\\Virtual Hard Disks\\packer-vyos13x.vhdx"
    data_disk_ref = {
      backend = "local"
      config = {
        path = "../Disk-VyOS-Data/terraform.tfstate"
      }
    }
  }
  nic = [
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
  enable_secure_boot = "Off"
  memory = {
    startup_bytes = 4093640704
    maximum_bytes = 4093640704
    minimum_bytes = 1023410176
  }
}

cloudinit_nocloud = [
  {
    content_source = "./cloudinit-tmpl/meta-data"
    content_vars = {
      instance_id    = "iid-VyOS_202412"
      local_hostname = "VyOS"
    }
    filename = "meta-data"
  },
  {
    content_source = "./cloudinit-tmpl/user-data-circinus"
    content_vars = {
      int_desc        = "MGMT"
      int_addr        = "192.168.255.1"
      int_cidr        = "192.168.255.0/24"
      dhcp_subnet_id  = "1"
      dhcp_start      = "192.168.255.100"
      dhcp_stop       = "192.168.255.200"
      dns_forward_1   = "223.5.5.5"
      dns_forward_2   = "223.6.6.6"
      api_key_id      = "MY-HTTPS-API-ID"
      api_key_content = "MY-HTTPS-API-PLAINTEXT-KEY"
      api_fqdn        = "vyos-api.day0.sololab"
      local_hostname  = "VyOS"
      user_ssh_key    = "AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ=="
      ntp_server      = "cn.ntp.org.cn"
      time_zone       = "Asia/Shanghai"
    }
    filename = "user-data"
  }
]
