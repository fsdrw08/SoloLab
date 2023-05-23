module "hyperv_machine_instance" {
  providers = {

  }
  source = "../modules/hyperv_instance"
  hyperv_machine_instance = {
    test = {
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
    test2 = {
      name                 = "test2"
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
  }
}
