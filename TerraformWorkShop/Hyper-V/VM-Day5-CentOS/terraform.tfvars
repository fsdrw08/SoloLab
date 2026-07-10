prov_hyperv = {
  host     = "192.168.255.100"
  port     = 5986
  user     = "root"
  password = "P@ssw0rd"
}

prov_vault = {
  schema          = "https"
  address         = "vault.day1.sololab"
  skip_tls_verify = true
}

vm = {
  count     = 1
  base_name = "Day5-CentOS"
  vhd = {
    dir    = "C:\\ProgramData\\Microsoft\\Windows\\Virtual Hard Disks"
    source = "C:\\ProgramData\\Microsoft\\Windows\\Virtual Hard Disks\\Images\\packer-hyperv_g2-centos-stream-10\\Virtual Hard Disks\\packer-centos-stream-10.vhdx"
  }
  nic = [
    {
      name                = "LAN1"
      switch_name         = "Internal Switch"
      dynamic_mac_address = true
    },
  ]
  enable_secure_boot = "On"
  power_state        = "Running"
  processor_count    = 2
  memory = {
    dynamic       = true
    startup_bytes = 2046820352
    maximum_bytes = 2046820352
    minimum_bytes = 511705088
  }
}

cloudinit = {
  files = [
    "./attachments/meta-data",
    "./attachments/network-config",
    "./attachments/user-data"
  ]
  vars = {
    global = {
      instance_id         = "iid-CentOS_202604"
      time_zone           = "Asia/Shanghai"
      packages            = <<-EOF
      [
        "bash-completion",
        "git",
        "podman",
        "cockpit",
        "cockpit-podman",
        "java-25-openjdk-devel"
      ]
      EOF
      custom_root_ca_url  = "http://dufs.day1.sololab/public/certs/sololab_root.crt"
      custom_root_ca_path = "/etc/pki/ca-trust/source/anchors"
      custom_bin_dir      = "/opt/bin"
      # consul client
      consul_download_url = "http://dufs.day1.sololab/public/binaries/consul_2.0.1_linux_amd64.zip"
      consul_version      = "2.0.1"
      consul_server_fqdn  = "consul.service.consul"
      consul_config_dir   = "/etc/consul.d"
      consul_data_dir     = "/var/lib/consul"
      # nomad client
      nomad_download_url                  = "http://dufs.day1.sololab/public/binaries/nomad_2.0.3_linux_amd64.zip"
      nomad_version                       = "2.0.3"
      nomad_server_fqdn                   = "nomad.service.consul"
      nomad_podman_driver_download_url    = "http://dufs.day1.sololab/public/binaries/nomad-driver-podman_0.6.4_linux_amd64.zip"
      nomad_podman_driver_version         = "0.6.4"
      nomad_client_cert_download_url      = "http://dufs.day1.sololab/private/certs/client.global.nomad.crt"
      nomad_client_cert_key_download_url  = "http://dufs.day1.sololab/private/certs/client.global.nomad.key"
      nomad_client_cert_download_url_cred = "YWRtaW46YWRtaW4="
      nomad_config_dir                    = "/etc/nomad.d"
      nomad_data_dir                      = "/var/lib/nomad"
      vault_server_address                = "https://vault.day1.sololab"
      # mise
      mise_script_download_url = "http://dufs.day1.sololab/public/binaries/mise-v2026.4.24-install.sh"
      mise_download_url        = "https://dufs.day1.sololab/public/binaries/mise-v2026.4.24-linux-x64.tar.gz"
    }
    local = [
      {
        local_hostname = "day5-centos"
      }
    ]
    value_refers = {
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
          name  = "token-consul_client"
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
          name  = "token-nomad_client"
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
