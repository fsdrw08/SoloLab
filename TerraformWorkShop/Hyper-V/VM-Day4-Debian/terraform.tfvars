prov_hyperv = {
  host     = "127.0.0.1"
  port     = 5986
  user     = "root"
  password = "P@ssw0rd"
}

vm = {
  count     = 1
  base_name = "Day4-Debian"
  vhd = {
    dir    = "C:\\ProgramData\\Microsoft\\Windows\\Virtual Hard Disks"
    source = "C:\\ProgramData\\Microsoft\\Windows\\Virtual Hard Disks\\Images\\packer-hyperv_g2-debian13\\Virtual Hard Disks\\packer-debian13.vhdx"
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

cloudinit_nocloud = [
  {
    content_source = "./cloudinit-tmpl/meta-data"
    content_vars = {
      instance_id    = "iid-Debian_202604"
      local_hostname = "Day4-Debian"
    }
    filename = "meta-data"
  },
  #   {
  #     content_source = "./cloudinit-tmpl/network-config"
  #     filename       = "network-config"
  #   },
  {
    content_source = "./cloudinit-tmpl/user-data"
    content_vars = {
      time_zone     = "Asia/Shanghai"
      "root_ca_url" = "http://dufs.day0.sololab/public/certs/sololab_root.crt"
      # consul client
      "consul_download_url" = "http://dufs.day0.sololab/public/binaries/consul_1.22.6_linux_amd64.zip"
      "consul_version"      = "1.22.6"
      "consul_server_fqdn"  = "consul.service.consul"
      "consul_data_dir"     = "/var/mnt/data/consul"
      # nomad client
      "nomad_download_url"                  = "http://dufs.day0.sololab/public/binaries/nomad_1.11.3_linux_amd64.zip"
      "nomad_version"                       = "1.11.3"
      "nomad_server_fqdn"                   = "nomad.service.consul"
      "nomad_podman_driver_download_url"    = "http://dufs.day0.sololab/public/binaries/nomad-driver-podman_0.6.4_linux_amd64.zip"
      "nomad_podman_driver_version"         = "0.6.4"
      "nomad_client_cert_download_url"      = "http://dufs.day0.sololab/private/certs/client.global.nomad.crt"
      "nomad_client_cert_key_download_url"  = "http://dufs.day0.sololab/private/certs/client.global.nomad.key"
      "nomad_client_cert_download_url_cred" = "YWRtaW46YWRtaW4="
      "nomad_data_dir"                      = "/var/mnt/data/nomad"
      "vault_server_address"                = "https://vault.day0.sololab"
    }
    filename = "user-data"
  }
]
