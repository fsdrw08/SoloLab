prov_hyperv = {
  host     = "127.0.0.1"
  port     = 5986
  user     = "root"
  password = "P@ssw0rd"
}

prov_vault = {
  address         = "https://vault.day1.sololab"
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
  processor_count    = 4
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
      "./Butane/network.yaml",
      "./Butane/packages-aliyun.yaml",
      "./Butane/storage.yaml",
      "./Butane/user-1000.yaml",
      "./Butane/user-1001.yaml",
    ]
  }
  vars = {
    global = {
      "timezone"    = "Asia/Shanghai"
      "interface"   = "eth0"
      "prefix"      = 24
      "gateway"     = "192.168.255.1"
      "general_dns" = "192.168.255.1;192.168.255.10"
      "domain"      = "sololab."
      "domain_dns"  = "192.168.255.10"
      "packages"    = "cockpit-system cockpit-ostree cockpit-podman cockpit-networkmanager cockpit-bridge pcp-zeroconf xfsdump"
    }
    local = [
      {
        "vm_name"            = "day2"
        "ip"                 = "192.168.255.20"
        "fcos_image_mirror"  = "zot.day1.sololab/fedora/fedora-coreos"
        "fcos_rebase_mirror" = "ostree-unverified-registry:zot.day1.sololab/fedora/fedora-coreos:stable"
      }
    ]
    value_refers = [
      {
        vault_kvv2 = {
          mount = "kvv2_certs"
          name  = "sololab_root"
        }
        value_sets = [
          {
            name          = "ca_content"
            value_ref_key = "ca"
          }
        ]
      },
      {
        vault_kvv2 = {
          mount = "kvv2_others"
          name  = "vm-day2"
        }
        value_sets = [
          {
            name          = "password_hash_1000"
            value_ref_key = "root_password_hash"
          },
          {
            name          = "ssh_authorized_key_1000"
            value_ref_key = "root_ssh_authorized_key"
          },
          {
            name          = "password_hash_1001"
            value_ref_key = "rootless_password_hash"
          },
          {
            name          = "ssh_authorized_key_1001"
            value_ref_key = "rootless_ssh_authorized_key"
          },
        ]
      }
    ]
  }
}
