prov_hyperv = {
  host     = "127.0.0.1"
  port     = 5986
  user     = "root"
  password = "P@ssw0rd"
}

vm = {
  count = 1
  name  = "SvcDisc-FCOS"
  vhd = {
    dir    = "C:\\ProgramData\\Microsoft\\Windows\\Virtual Hard Disks"
    source = "C:\\ProgramData\\Microsoft\\Windows\\Virtual Hard Disks\\Images\\fcos\\fedora-coreos-hyperv.x86_64.vhdx"
    data_disk_ref = {
      backend = "pg"
      config = {
        "conn_str"    = "postgres://terraform:terraform@postgresql.day0.sololab/tfstate"
        "schema_name" = "HyperV-SvcDisc-Disk-FCOS"
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
  memory = {
    startup_bytes = 2046820352
    maximum_bytes = 2046820352
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
      "./Butane/user.yaml",
    ]
  }
  vars = {
    "vm_name"                    = "SvcDisc-FCOS"
    "timezone"                   = "Asia/Shanghai"
    "interface"                  = "eth0"
    "ip"                         = "192.168.255.20"
    "prefix"                     = 24
    "gateway"                    = "192.168.255.1"
    "dns"                        = "192.168.255.1"
    "packages"                   = "cockpit-system cockpit-ostree cockpit-podman cockpit-networkmanager cockpit-bridge"
    "core_password_hash"         = "$y$j9T$cDLwsV9ODTV31Dt4SuVGa.$FU0eRT9jawPhIV3IV24W7obZ3PaJuBCVp7C9upDCcgD"
    "core_ssh_authorized_keys"   = "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key"
    "podmgr_password_hash"       = "$y$j9T$I4IXP5reKRLKrkwuNjq071$yHlJulSZGzmyppGbdWHyFHw/D8Gl247J2J8P43UnQWA"
    "podmgr_ssh_authorized_keys" = "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key"
  }
}

prov_pdns = {
  api_key    = "powerdns"
  server_url = "https://pdns.day0.sololab"
}

dns_record = {
  zone = "day1.sololab."
  name = "SvcDisc-FCOS.day1.sololab."
  type = "A"
  ttl  = 86400
  records = [
    "192.168.255.20"
  ]
}
