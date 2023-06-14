# variable "vm_instance_count" {
#   type = number
# }
variable "vm_instance" {
  description = "hyperv vm instance config"
  type = object({
    name                                    = string
    automatic_critical_error_action         = optional(string, null)
    automatic_critical_error_action_timeout = optional(number, null)
    automatic_start_action                  = optional(string, null)
    automatic_start_delay                   = optional(number, null)
    automatic_stop_action                   = optional(string, null)
    checkpoint_type                         = optional(string, null)
    generation                              = optional(number, null)
    guest_controlled_cache_types            = optional(bool, null)
    high_memory_mapped_io_space             = optional(number, null)
    lock_on_disconnect                      = optional(string, null)
    low_memory_mapped_io_space              = optional(number, null)
    memory_maximum_bytes                    = optional(number, null)
    memory_minimum_bytes                    = optional(number, null)
    memory_startup_bytes                    = optional(number, null)
    notes                                   = optional(string, null)
    processor_count                         = optional(number, null)
    smart_paging_file_path                  = optional(string, null)
    snapshot_file_location                  = optional(string, null)
    dynamic_memory                          = optional(bool, null)
    static_memory                           = optional(bool, null)
    state                                   = optional(string, null)
    wait_for_ips_poll_period                = optional(number, null)
    wait_for_ips_timeout                    = optional(number, null)
    wait_for_state_poll_period              = optional(number, null)
    wait_for_state_timeout                  = optional(number, null)

    vm_firmware = optional(object({
      console_mode                    = optional(string, null)
      enable_secure_boot              = optional(string, null)
      secure_boot_template            = optional(string, null)
      preferred_network_boot_protocol = optional(string, null)
      pause_after_boot_failure        = optional(string, null)
      boot_order = optional(list(object({
        boot_type            = optional(string, null)
        controller_number    = optional(string, null)
        controller_location  = optional(string, null)
        mac_address          = optional(string, null)
        network_adapter_name = optional(string, null)
        path                 = optional(string, null)
        switch_name          = optional(string, null)
      })))
    }))

    vm_processor = optional(object({
      compatibility_for_migration_enabled               = optional(string, null)
      compatibility_for_older_operating_systems_enabled = optional(string, null)
      enable_host_resource_protection                   = optional(string, null)
      expose_virtualization_extensions                  = optional(string, null)
      hw_thread_count_per_core                          = optional(string, null)
      maximum                                           = optional(string, null)
      maximum_count_per_numa_node                       = optional(string, null)
      maximum_count_per_numa_socket                     = optional(string, null)
      relative_weight                                   = optional(string, null)
      reserve                                           = optional(string, null)
    }))

    integration_services = optional(object({
      Guest_Service_Interface = optional(bool, null)
      Heartbeat               = optional(bool, null)
      Key_Value_Pair          = optional(bool, null)
      Shutdown                = optional(bool, null)
      Time_Synchronization    = optional(bool, null)
      VSS                     = optional(bool, null)
    }))

    network_adaptors = optional(list(object({
      name                                       = string
      allow_teaming                              = optional(string, null)
      device_naming                              = optional(string, null)
      dhcp_guard                                 = optional(string, null)
      dynamic_ip_address_limit                   = optional(number, null)
      dynamic_mac_address                        = optional(bool, null)
      fix_speed_10g                              = optional(string, null)
      ieee_priority_tag                          = optional(string, null)
      iov_queue_pairs_requested                  = optional(number, null)
      iov_interrupt_moderation                   = optional(string, null)
      iov_weight                                 = optional(number, null)
      ipsec_offload_maximum_security_association = optional(number, null)
      is_legacy                                  = optional(bool, null)
      mac_address_spoofing                       = optional(string, null)
      management_os                              = optional(bool, null)
      mandatory_feature_id                       = optional(set(string), null)
      maximum_bandwidth                          = optional(number, null)
      minimum_bandwidth_absolute                 = optional(number, null)
      minimum_bandwidth_weight                   = optional(number, null)
      not_monitored_in_cluster                   = optional(bool, null)
      packet_direct_num_procs                    = optional(number, null)
      packet_direct_moderation_count             = optional(number, null)
      packet_direct_moderation_interval          = optional(number, null)
      port_mirroring                             = optional(string, null)
      resource_pool_name                         = optional(string, null)
      router_guard                               = optional(string, null)
      static_mac_address                         = optional(string, null)
      storm_limit                                = optional(number, null)
      switch_name                                = optional(string, null)
      test_replica_pool_name                     = optional(string, null)
      test_replica_switch_name                   = optional(string, null)
      virtual_subnet_id                          = optional(number, null)
      vlan_access                                = optional(bool, null)
      vlan_id                                    = optional(number, null)
      vmmq_enabled                               = optional(bool, null)
      vmmq_queue_pairs                           = optional(number, null)
      vmq_weight                                 = optional(number, null)
      vrss_enabled                               = optional(bool, null)
      wait_for_ips                               = optional(bool, null)
    })))

    dvd_drives = optional(list(object({
      controller_location = number
      controller_number   = number
      path                = optional(string, null)
      resource_pool_name  = optional(string, "Primordial")
    })))

    hard_disk_drives = optional(list(object({
      controller_location             = number
      controller_number               = number
      controller_type                 = optional(string, null)
      disk_number                     = optional(number, null)
      maximum_iops                    = optional(number, null)
      minimum_iops                    = optional(number, null)
      override_cache_attributes       = optional(string, null)
      path                            = optional(string, null)
      qos_policy_id                   = optional(string, null)
      resource_pool_name              = optional(string, null)
      support_persistent_reservations = optional(bool, null)
    })))

    timeouts = optional(object({
      create = optional(string, null)
      delete = optional(string, null)
      read   = optional(string, null)
      update = optional(string, null)
    }))
  })
}

# variable "boot_disk" {
#   type = object({
#     path                 = string
#     block_size           = optional(string, null)
#     logical_sector_size  = optional(number, null)
#     parent_path          = optional(string, null)
#     physical_sector_size = optional(number, null)
#     size                 = optional(number, null)
#     source               = optional(string, null)
#     source_disk          = optional(number, null)
#     source_vm            = optional(string, null)
#     vhd_type             = optional(string, null)
#     timeouts = object({
#       create = optional(string, null)
#       delete = optional(string, null)
#       read   = optional(string, null)
#       update = optional(string, null)
#     })
#   })
# }

# variable "additional_disks" {
#   type = optional(list(object({
#     path                 = string
#     block_size           = optional(string, null)
#     logical_sector_size  = optional(number, null)
#     parent_path          = optional(string, null)
#     physical_sector_size = optional(number, null)
#     size                 = optional(number, null)
#     source               = optional(string, null)
#     source_disk          = optional(number, null)
#     source_vm            = optional(string, null)
#     vhd_type             = optional(string, null)
#     timeouts = object({
#       create = optional(string, null)
#       delete = optional(string, null)
#       read   = optional(string, null)
#       update = optional(string, null)
#     })
#   })))
# }
