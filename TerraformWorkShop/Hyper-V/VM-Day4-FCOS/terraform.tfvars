prov_hyperv = {
  host     = "127.0.0.1"
  port     = 5986
  user     = "root"
  password = "P@ssw0rd"
}

prov_vault = {
  schema          = "https"
  address         = "vault.day1.sololab"
  token           = "95eba8ed-f6fc-958a-f490-c7fd0eda5e9e"
  skip_tls_verify = true
}

vm = {
  count     = 1
  base_name = "Day4-FCOS"
  vhd = {
    dir = "C:\\ProgramData\\Microsoft\\Windows\\Virtual Hard Disks"
    # https://fedoraproject.org/coreos/download?stream=stable
    # source = "C:\\ProgramData\\Microsoft\\Windows\\Virtual Hard Disks\\Images\\fcos\\fedora-coreos-hyperv.x86_64.vhdx"
    # in order to prevent juicefs mount issue in linux kernel 7.1.3,
    # pin FCOS version to 44.20260621.3.1
    # ref:
    #   - https://github.com/juicedata/juicefs/issues/7251
    #   - https://fedoraproject.org/coreos/release-notes/?stream=stable
    # https://builds.coreos.fedoraproject.org/prod/streams/stable/builds/44.20260621.3.1/x86_64/fedora-coreos-44.20260621.3.1-hyperv.x86_64.vhdx.zip
    source = "C:\\ProgramData\\Microsoft\\Windows\\Virtual Hard Disks\\Images\\fcos\\fedora-coreos-44.20260621.3.1-hyperv.x86_64.vhdx"
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
  cpu_core           = 4
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
      # "./Butane/network.yaml",
      "./Butane/packages.yaml",
      "./Butane/storage.yaml",
      "./Butane/user-1000.yaml",
      "./Butane/user-1001.yaml",
      "./Butane/consul.yaml",
      "./Butane/nomad.yaml",
    ]
  }
  vars = {
    global = {
      timezone = "Asia/Shanghai"
      # interface                = "eth0"
      # prefix                   = 24
      # gateway                  = "192.168.255.1"
      # general_dns              = "192.168.255.1;192.168.255.10"
      # domain                   = "sololab."
      # domain_dns               = "192.168.255.10"
      packages            = "cockpit-system cockpit-ostree cockpit-podman cockpit-networkmanager cockpit-bridge pcp-zeroconf"
      root_ca_url         = "http://dufs.day1.sololab/public/certs/sololab_root.crt"
      fcos_image_mirror   = "zot.day1.sololab/fedora/fedora-coreos"
      fcos_rebase_mirror  = "ostree-unverified-registry:zot.day1.sololab/fedora/fedora-coreos:stable"
      custom_root_ca_path = "/etc/pki/ca-trust/source/anchors"
      custom_bin_dir      = "/opt/bin"
      # consul client
      consul_install_url  = "http://dufs.day1.sololab/public/binaries/consul_install.sh"
      consul_download_url = "http://dufs.day1.sololab/public/binaries/consul_2.0.2_linux_amd64.zip"
      consul_server_fqdn  = "consul.service.consul"
      consul_config_dir   = "/etc/consul.d"
      consul_data_dir     = "/var/mnt/data/consul"
      # nomad client
      nomad_install_url                   = "http://dufs.day1.sololab/public/binaries/nomad_install.sh"
      nomad_download_url                  = "http://dufs.day1.sololab/public/binaries/nomad_2.0.4_linux_amd64.zip"
      nomad_server_fqdn                   = "nomad.service.consul"
      nomad_podman_driver_install_url     = "http://dufs.day1.sololab/public/binaries/nomad_driver_podman_install.sh"
      nomad_podman_driver_download_url    = "http://dufs.day1.sololab/public/binaries/nomad-driver-podman_0.6.5_linux_amd64.zip"
      nomad_client_cert_download_url      = "http://dufs.day1.sololab/private/certs/client.global.nomad.crt"
      nomad_client_cert_key_download_url  = "http://dufs.day1.sololab/private/certs/client.global.nomad.key"
      nomad_client_cert_download_url_cred = "YWRtaW46YWRtaW4="
      nomad_config_dir                    = "/etc/nomad.d"
      nomad_data_dir                      = "/var/mnt/data/nomad"
      vault_server_address                = "https://vault.day1.sololab"
    }
    local = [
      {
        # ip                                 = "192.168.255.30"
        vm_name = "day4"
      },
      # {
      #   # ip = "192.168.255.30"
      #   vm_name = "ci-2"
      # }
    ]
    value_refers = {
      password_hash_1000 = {
        vault_kvv2 = {
          mount = "kvv2_others"
          name  = "vm-day4"
          key   = "root_password_hash"
        }
      }
      ssh_authorized_key_1000 = {
        vault_kvv2 = {
          mount = "kvv2_others"
          name  = "vm-day4"
          key   = "root_ssh_authorized_key"
        }
      }
      password_hash_1001 = {
        vault_kvv2 = {
          mount = "kvv2_others"
          name  = "vm-day4"
          key   = "rootless_password_hash"
        }
      }
      ssh_authorized_key_1001 = {
        vault_kvv2 = {
          mount = "kvv2_others"
          name  = "vm-day4"
          key   = "rootless_ssh_authorized_key"
        }
      }
      consul_ca_content = {
        vault_kvv2 = {
          mount = "kvv2_certs"
          name  = "consul_root"
          key   = "ca"
        }
      }
      consul_acl_token = {
        vault_kvv2 = {
          mount = "kvv2_consul"
          name  = "token-role-consul_client"
          key   = "token"
        }
      }
      consul_encrypt_key = {
        vault_kvv2 = {
          mount = "kvv2_consul"
          name  = "key-gossip_encryption"
          key   = "key"
        }
      }
      nomad_consul_acl_token = {
        vault_kvv2 = {
          mount = "kvv2_consul"
          name  = "token-role-nomad_client"
          key   = "token"
        }
      }
      nomad_acl_token = {
        vault_kvv2 = {
          mount = "kvv2_nomad"
          name  = "token-node_write"
          key   = "token"
        }
      }
    }
  }
}
