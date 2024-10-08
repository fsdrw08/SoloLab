vm_name = "VyOS-140-GA"

cloudinit_nocloud = [
  {
    content_source = "./cloudinit-tmpl/meta-data"
    content_vars = {
      instance_id    = "iid-VyOS_20241005"
      local_hostname = "VyOS-140"
    }
    filename = "meta-data"
  },
  {
    content_source = "./cloudinit-tmpl/user-data-sagitta"
    content_vars = {
      int_desc        = "MGMT"
      int_addr        = "192.168.255.1"
      int_cidr        = "192.168.255.0/24"
      dhcp_start      = "192.168.255.100"
      dhcp_stop       = "192.168.255.200"
      dns_forward_1   = "223.5.5.5"
      dns_forward_2   = "223.6.6.6"
      api_key_id      = "MY-HTTPS-API-ID"
      api_key_content = "MY-HTTPS-API-PLAINTEXT-KEY"
      api_fqdn        = "vyos-api.mgmt.sololab"
      local_hostname  = "VyOS-140"
      user_ssh_key    = "AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ=="
      ntp_server      = "cn.ntp.org.cn"
      time_zone       = "Asia/Shanghai"
    }
    filename = "user-data"
  }
]
