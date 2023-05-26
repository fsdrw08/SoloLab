locals {
  cloud_init = {
    path = "./cloud-init1.iso"
    content = {
      # https://cloudinit.readthedocs.io/en/latest/reference/datasources/nocloud.html#configuration-methods
      # https://developer.hashicorp.com/terraform/language/expressions/strings#indented-heredocs
      user-data      = <<-EOT
        #cloud-config
        timezone: Asia/Shanghai
        EOT
      network-config = <<-EOT
        version: 2
        ethernets:
          eth0:
            dhcp4: true
        EOT
    }
  }

  hyperv_machine_instance = {
    name                 = "test"
    state                = "Off"
    static_memory        = true
    memory_startup_bytes = 536870912

    vm_firmware = {
      console_mode                    = "Default"
      enable_secure_boot              = "On"
      secure_boot_template            = "MicrosoftUEFICertificateAuthority"
      pause_after_boot_failure        = "Off"
      preferred_network_boot_protocol = "IPv4"
      boot_order = [
        {
          boot_type           = "HardDiskDrive"
          controller_number   = "0"
          controller_location = "0"
        },
        {
          boot_type           = "HardDiskDrive"
          controller_number   = "0"
          controller_location = "1"
        },
      ]
    }

    vm_processor = {
      compatibility_for_migration_enabled               = false
      compatibility_for_older_operating_systems_enabled = false
      enable_host_resource_protection                   = false
      expose_virtualization_extensions                  = false
      hw_thread_count_per_core                          = 0
      maximum                                           = 100
      maximum_count_per_numa_node                       = 4
      maximum_count_per_numa_socket                     = 1
      relative_weight                                   = 100
      reserve                                           = 0
    }

    network_adaptors = [
      {
        name        = "Internal Switch"
        switch_name = "Internal Switch"
      },
      {
        name        = "Internal Switch"
        switch_name = "Internal Switch"
      },
    ]

    dvd_drives = [
      {
        controller_number   = 0
        controller_location = 1
        path                = "/test/123"
      }
    ]
  }

  vhd_dir = "C:\\ProgramData\\Microsoft\\Windows\\Virtual Hard Disks"
}
module "hyperv_machine_instance" {
  source            = "../modules/hyperv_instance"
  vm_instance       = local.hyperv_machine_instance
  vm_instance_count = 2
}
