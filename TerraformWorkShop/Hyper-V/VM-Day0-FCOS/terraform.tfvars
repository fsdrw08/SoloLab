prov_hyperv = {
  host     = "127.0.0.1"
  port     = 5986
  user     = "root"
  password = "P@ssw0rd"
}

vm = {
  count     = 1
  base_name = "Day0-FCOS"
  vhd = {
    dir = "C:\\ProgramData\\Microsoft\\Windows\\Virtual Hard Disks"
    # https://fedoraproject.org/coreos/download?stream=stable
    source = "C:\\ProgramData\\Microsoft\\Windows\\Virtual Hard Disks\\Images\\fcos\\fedora-coreos-hyperv.x86_64.vhdx"
    data_disk_tfstate = {
      backend = {
        type = "local"
        config = {
          path = "../Disks-Data/terraform.tfstate"
        }
      }
    }
  }
  nic = [
    {
      name                = "LAN1"
      switch_name         = "Internal Switch"
      dynamic_mac_address = true
      # static_mac_address  = "0000FEE1600D"
    },
  ]
  enable_secure_boot = "On"
  power_state        = "Off"
  memory = {
    dynamic       = true
    startup_bytes = 4093640704
    maximum_bytes = 4093640704
    minimum_bytes = 1023410176
  }
}

butane = {
  files = {
    base = "./Butane/base.yaml"
    others = [
      "./Butane/network.yaml",
      "./Butane/packages.yaml",
      "./Butane/storage.yaml",
      "./Butane/user-core.yaml",
      "./Butane/user.yaml",
    ]
  }
  vars = {
    global = {
      "timezone"                   = "Asia/Shanghai"
      "interface"                  = "eth0"
      "prefix"                     = 24
      "gateway"                    = "192.168.255.1"
      "general_dns"                = "192.168.255.1;192.168.255.10"
      "domain"                     = "sololab."
      "domain_dns"                 = "192.168.255.10"
      "packages"                   = "cockpit-system cockpit-ostree cockpit-podman cockpit-networkmanager cockpit-bridge xfsdump unzip"
      "core_password_hash"         = "$y$j9T$cDLwsV9ODTV31Dt4SuVGa.$FU0eRT9jawPhIV3IV24W7obZ3PaJuBCVp7C9upDCcgD"
      "core_ssh_authorized_keys"   = "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key"
      "podmgr_password_hash"       = "$y$j9T$I4IXP5reKRLKrkwuNjq071$yHlJulSZGzmyppGbdWHyFHw/D8Gl247J2J8P43UnQWA"
      "podmgr_ssh_authorized_keys" = "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key"
    }
    local = [
      {
        "vm_name" = "Day0-FCOS"
        "ip"      = "192.168.255.10"
      }
    ]
  }
}

# prov_pdns = {
#   api_key    = "powerdns"
#   server_url = "https://pdns.day0.sololab"
# }

# dns_record = {
#   zone = "day1.sololab."
#   name = "Infra-FCOS.day1.sololab."
#   type = "A"
#   ttl  = 86400
#   records = [
#     "192.168.255.10"
#   ]
# }
