prov_hyperv = {
  host     = "127.0.0.1"
  port     = 5986
  user     = "root"
  password = "P@ssw0rd"
}

prov_vault = {
  schema          = "https"
  address         = "vault.day0.sololab"
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
    # data_disk_tfstate = {
    #   backend = {
    #     type = "local"
    #     config = {
    #       path = "../Disks-Data/terraform.tfstate"
    #     }
    #   }
    # }
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
    startup_bytes = 2046820352
    maximum_bytes = 2046820352
    minimum_bytes = 1023410176
  }
}

butane = {
  files = {
    base = "./Butane/base.yaml"
    others = [
      # "./Butane/network.yaml",
      "./Butane/packages.yaml",
      # "./Butane/storage.yaml",
      "./Butane/user-1000.yaml",
      "./Butane/user-1001.yaml",
      "./Butane/consul.yaml",
      "./Butane/nomad.yaml",
    ]
  }
  vars = {
    global = {
      "timezone" = "Asia/Shanghai"
      # "interface"                = "eth0"
      # "prefix"                   = 24
      # "gateway"                  = "192.168.255.1"
      # "general_dns"              = "192.168.255.1;192.168.255.10"
      # "domain"                   = "sololab."
      # "domain_dns"               = "192.168.255.10"
      "packages"                 = "cockpit-system cockpit-ostree cockpit-podman cockpit-networkmanager cockpit-bridge pcp-zeroconf"
      "password_hash_1000"       = "$y$j9T$cDLwsV9ODTV31Dt4SuVGa.$FU0eRT9jawPhIV3IV24W7obZ3PaJuBCVp7C9upDCcgD"
      "ssh_authorized_keys_1000" = "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key"
      "password_hash_1001"       = "$y$j9T$I4IXP5reKRLKrkwuNjq071$yHlJulSZGzmyppGbdWHyFHw/D8Gl247J2J8P43UnQWA"
      "ssh_authorized_keys_1001" = "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key"
      "root_ca_url"              = "http://dufs.day0.sololab/public/certs/sololab_root.crt"
      # nomad client
      "fcos_image_mirror"                   = "zot.day0.sololab/fedora/fedora-coreos"
      "fcos_rebase_mirror"                  = "ostree-unverified-registry:zot.day0.sololab/fedora/fedora-coreos:stable"
      "consul_download_url"                 = "http://dufs.day0.sololab/public/binaries/consul_1.22.0_linux_amd64.zip"
      "consul_version"                      = "1.22.0"
      "consul_server_fqdn"                  = "consul.service.consul"
      "nomad_download_url"                  = "http://dufs.day0.sololab/public/binaries/nomad_1.11.0_linux_amd64.zip"
      "nomad_version"                       = "1.11.0"
      "nomad_server_fqdn"                   = "nomad.service.consul"
      "nomad_podman_driver_download_url"    = "http://dufs.day0.sololab/public/binaries/nomad-driver-podman_0.6.3_linux_amd64.zip"
      "nomad_podman_driver_version"         = "0.6.3"
      "nomad_client_cert_download_url"      = "http://dufs.day0.sololab/private/certs/client.global.nomad.crt"
      "nomad_client_cert_key_download_url"  = "http://dufs.day0.sololab/private/certs/client.global.nomad.key"
      "nomad_client_cert_download_url_cred" = "YWRtaW46YWRtaW4="
      "vault_server_address"                = "https://vault.day0.sololab"
    }
    local = [
      {
        # "ip"                                 = "192.168.255.30"
        "vm_name" = "day2"
      },
      # {
      #   # "ip"                                 = "192.168.255.30"
      #   "vm_name" = "day2-2"
      # }
    ]
    secrets = [
      {
        vault_kvv2 = {
          mount = "kvv2_certs"
          name  = "consul_root"
        }
        value_sets = [
          {
            name          = "consul_ca_content"
            value_ref_key = "ca"
          }
        ]
      },
      {
        vault_kvv2 = {
          mount = "kvv2_consul"
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
          mount = "kvv2_consul"
          name  = "key-gossip_encryption"
        }
        value_sets = [
          {
            name          = "consul_encrypt_key"
            value_ref_key = "key"
          }
        ]
      },
      {
        vault_kvv2 = {
          mount = "kvv2_consul"
          name  = "token-nomad_client"
        }
        value_sets = [
          {
            name          = "nomad_consul_acl_token"
            value_ref_key = "token"
          }
        ]
      },
      {
        vault_kvv2 = {
          mount = "kvv2_nomad"
          name  = "token-node_write"
        }
        value_sets = [
          {
            name          = "nomad_acl_token"
            value_ref_key = "token"
          }
        ]
      },
    ]
  }
}
