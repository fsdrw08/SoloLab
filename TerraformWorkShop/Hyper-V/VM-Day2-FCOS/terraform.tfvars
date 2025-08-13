prov_hyperv = {
  host     = "127.0.0.1"
  port     = 5986
  user     = "root"
  password = "P@ssw0rd"
}

prov_vault = {
  schema          = "https"
  address         = "vault.day1.sololab:8200"
  token           = "95eba8ed-f6fc-958a-f490-c7fd0eda5e9e"
  skip_tls_verify = true
}

vm = {
  count     = 1
  base_name = "Day2-FCOS"
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
      "./Butane/user-1000.yaml",
      "./Butane/user-1001.yaml",
      "./Butane/consul.yaml",
    ]
  }
  vars = {
    global = {
      "timezone"                 = "Asia/Shanghai"
      "interface"                = "eth0"
      "prefix"                   = 24
      "gateway"                  = "192.168.255.1"
      "general_dns"              = "192.168.255.10"
      "domain"                   = "sololab."
      "domain_dns"               = "192.168.255.10"
      "packages"                 = "cockpit-system cockpit-ostree cockpit-podman cockpit-networkmanager cockpit-bridge"
      "password_hash_1000"       = "$y$j9T$cDLwsV9ODTV31Dt4SuVGa.$FU0eRT9jawPhIV3IV24W7obZ3PaJuBCVp7C9upDCcgD"
      "ssh_authorized_keys_1000" = "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key"
      "password_hash_1001"       = "$y$j9T$I4IXP5reKRLKrkwuNjq071$yHlJulSZGzmyppGbdWHyFHw/D8Gl247J2J8P43UnQWA"
      "ssh_authorized_keys_1001" = "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key"
    }
    local = [
      {
        "vm_name"             = "Day2-FCOS"
        "ip"                  = "192.168.255.30"
        "consul_download_url" = "http://dufs.day0.sololab/binaries/consul_1.21.3_linux_amd64.zip"
        "consul_version"      = "1.21.3"
        "consul_server_fqdn"  = "consul.day1.sololab"
        "ca_download_url"     = "http://dufs.day0.sololab/certs/root.crt"
      }
    ]
    secrets = [
      {
        vault_kvv2 = {
          mount = "kvv2/consul"
          name  = "token-consul_client"
        }
        value_sets = [
          {
            name          = "consul_acl_token"
            value_ref_key = "token"
          }
        ]
      },
      {
        vault_kvv2 = {
          mount = "kvv2/consul"
          name  = "key-gossip_encryption"
        }
        value_sets = [
          {
            name          = "consul_encrypt_key"
            value_ref_key = "key"
          }
        ]
      },
    ]
  }
}

prov_pdns = {
  api_key    = "powerdns"
  server_url = "https://pdns-auth.day0.sololab"
}

dns_record = {
  zone = "day2.sololab."
  name = "FCOS.day2.sololab."
  type = "A"
  ttl  = 86400
  records = [
    "192.168.255.30"
  ]
}
