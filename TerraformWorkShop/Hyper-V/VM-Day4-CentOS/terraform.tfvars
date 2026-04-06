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
  base_name = "Day4-CentOS"
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
    "./cloudinit-tmpl/meta-data",
    "./cloudinit-tmpl/user-data"
  ]
  vars = {
    global = {
      instance_id = "iid-CentOS_202604"
      time_zone   = "Asia/Shanghai"
      root_ca_url = "http://dufs.day0.sololab/public/certs/sololab_root.crt"
      # consul client
      consul_download_url = "http://dufs.day0.sololab/public/binaries/consul_1.22.6_linux_amd64.zip"
      consul_version      = "1.22.6"
      consul_server_fqdn  = "consul.service.consul"
      consul_data_dir     = "/opt/consul"
      # nomad client
      nomad_download_url                  = "http://dufs.day0.sololab/public/binaries/nomad_1.11.3_linux_amd64.zip"
      nomad_version                       = "1.11.3"
      nomad_server_fqdn                   = "nomad.service.consul"
      nomad_podman_driver_download_url    = "http://dufs.day0.sololab/public/binaries/nomad-driver-podman_0.6.4_linux_amd64.zip"
      nomad_podman_driver_version         = "0.6.4"
      nomad_client_cert_download_url      = "http://dufs.day0.sololab/private/certs/client.global.nomad.crt"
      nomad_client_cert_key_download_url  = "http://dufs.day0.sololab/private/certs/client.global.nomad.key"
      nomad_client_cert_download_url_cred = "YWRtaW46YWRtaW4="
      nomad_data_dir                      = "/opt/nomad"
      vault_server_address                = "https://vault.day0.sololab"
    }
    local = [
      {
        local_hostname = "Day4-CentOS"
      }
    ]
    value_refers = [
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
