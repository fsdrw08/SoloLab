resource "hyperv_machine_instance" "vm_instance" {

  name                                    = var.name
  generation                              = var.generation
  automatic_critical_error_action         = var.automatic_critical_error_action
  automatic_critical_error_action_timeout = var.automatic_critical_error_action_timeout
  automatic_start_action                  = var.automatic_start_action
  automatic_start_delay                   = var.automatic_start_delay
  automatic_stop_action                   = var.automatic_stop_action
  checkpoint_type                         = var.checkpoint_type
  guest_controlled_cache_types            = var.guest_controlled_cache_types
  high_memory_mapped_io_space             = var.high_memory_mapped_io_space
  lock_on_disconnect                      = var.lock_on_disconnect
  low_memory_mapped_io_space              = var.low_memory_mapped_io_space
  memory_maximum_bytes                    = var.memory_maximum_bytes
  memory_minimum_bytes                    = var.memory_minimum_bytes
  memory_startup_bytes                    = var.memory_startup_bytes
  notes                                   = var.notes
  processor_count                         = var.processor_count
  smart_paging_file_path                  = var.smart_paging_file_path
  snapshot_file_location                  = var.snapshot_file_location
  dynamic_memory                          = var.dynamic_memory
  static_memory                           = var.static_memory
  state                                   = var.state

  vm_firmware {
    console_mode                    = var.vm_firmware.console_mode
    enable_secure_boot              = var.vm_firmware.enable_secure_boot
    secure_boot_template            = var.vm_firmware.secure_boot_template
    preferred_network_boot_protocol = var.vm_firmware.preferred_network_boot_protocol
    pause_after_boot_failure        = var.vm_firmware.pause_after_boot_failure
    dynamic "boot_order" {
      # https://github.com/terraform-google-modules/terraform-google-vm/blob/master/modules/instance_template/main.tf#LL97C30-L97C30
      for_each = var.vm_firmware.boot_order == null ? [] : [var.vm_firmware.boot_order]
      content {
        boot_type            = vm_firmware.boot_order.value["boot_type"]
        controller_number    = vm_firmware.boot_order.value["controller_number"]
        controller_location  = vm_firmware.boot_order.value["controller_location"]
        mac_address          = vm_firmware.boot_order.value["mac_address"]
        network_adapter_name = vm_firmware.boot_order.value["network_adapter_name"]
        path                 = vm_firmware.boot_order.value["path"]
        switch_name          = vm_firmware.boot_order.value["switch_name"]
      }
    }
  }

  vm_processor {
    compatibility_for_migration_enabled               = var.vm_processor.compatibility_for_migration_enabled
    compatibility_for_older_operating_systems_enabled = var.vm_processor.compatibility_for_older_operating_systems_enabled
    enable_host_resource_protection                   = var.vm_processor.enable_host_resource_protection
    expose_virtualization_extensions                  = var.vm_processor.expose_virtualization_extensions
    hw_thread_count_per_core                          = var.vm_processor.hw_thread_count_per_core
    maximum                                           = var.vm_processor.maximum
    maximum_count_per_numa_node                       = var.vm_processor.maximum_count_per_numa_node
    maximum_count_per_numa_socket                     = var.vm_processor.maximum_count_per_numa_socket
    relative_weight                                   = var.vm_processor.relative_weight
    reserve                                           = var.vm_processor.reserve
  }

  integration_services = {
    "Guest Service Interface" = var.integration_services.Guest_Service_Interface
    "Heartbeat"               = var.integration_services.Heartbeat
    "Key-Value Pair Exchange" = var.integration_services.Key_Value_Pair
    "Shutdown"                = var.integration_services.Shutdown
    "Time Synchronization"    = var.integration_services.Time_Synchronization
    "VSS"                     = var.integration_services.VSS
  }

  dynamic "network_adaptors" {
    for_each = var.network_adaptors
    content {
      name                                       = network_adaptors.value["name"]
      switch_name                                = network_adaptors.value["switch_name"]
      management_os                              = network_adaptors.value["management_os"]
      is_legacy                                  = network_adaptors.value["is_legacy"]
      dynamic_mac_address                        = network_adaptors.value["dynamic_mac_address"]
      static_mac_address                         = network_adaptors.value["static_mac_address"]
      mac_address_spoofing                       = network_adaptors.value["mac_address_spoofing"]
      dhcp_guard                                 = network_adaptors.value["dhcp_guard"]
      router_guard                               = network_adaptors.value["router_guard"]
      port_mirroring                             = network_adaptors.value["port_mirroring"]
      ieee_priority_tag                          = network_adaptors.value["ieee_priority_tag"]
      vmq_weight                                 = network_adaptors.value["vmq_weight"]
      iov_queue_pairs_requested                  = network_adaptors.value["iov_queue_pairs_requested"]
      iov_interrupt_moderation                   = network_adaptors.value["iov_interrupt_moderation"]
      iov_weight                                 = network_adaptors.value["iov_weight"]
      ipsec_offload_maximum_security_association = network_adaptors.value["ipsec_offload_maximum_security_association"]
      maximum_bandwidth                          = network_adaptors.value["maximum_bandwidth"]
      minimum_bandwidth_absolute                 = network_adaptors.value["minimum_bandwidth_absolute"]
      minimum_bandwidth_weight                   = network_adaptors.value["minimum_bandwidth_weight"]
      mandatory_feature_id                       = network_adaptors.value["mandatory_feature_id"]
      resource_pool_name                         = network_adaptors.value["resource_pool_name"]
      test_replica_pool_name                     = network_adaptors.value["test_replica_pool_name"]
      test_replica_switch_name                   = network_adaptors.value["test_replica_switch_name"]
      virtual_subnet_id                          = network_adaptors.value["virtual_subnet_id"]
      allow_teaming                              = network_adaptors.value["allow_teaming"]
      not_monitored_in_cluster                   = network_adaptors.value["not_monitored_in_cluster"]
      storm_limit                                = network_adaptors.value["storm_limit"]
      dynamic_ip_address_limit                   = network_adaptors.value["dynamic_ip_address_limit"]
      device_naming                              = network_adaptors.value["device_naming"]
      fix_speed_10g                              = network_adaptors.value["fix_speed_10g"]
      packet_direct_num_procs                    = network_adaptors.value["packet_direct_num_procs"]
      packet_direct_moderation_count             = network_adaptors.value["packet_direct_moderation_count"]
      packet_direct_moderation_interval          = network_adaptors.value["packet_direct_moderation_interval"]
      vrss_enabled                               = network_adaptors.value["vrss_enabled"]
      vmmq_enabled                               = network_adaptors.value["vmmq_enabled"]
      vmmq_queue_pairs                           = network_adaptors.value["vmmq_queue_pairs"]
    }
  }

  dynamic "dvd_drives" {
    for_each = var.dvd_drives
    content {
      controller_number   = dvd_drives.value["controller_number"]
      controller_location = dvd_drives.value["controller_location"]
      path                = dvd_drives.value["path"]
      resource_pool_name  = dvd_drives.value["resource_pool_name"]
    }
  }

  dynamic "hard_disk_drives" {
    for_each = var.hard_disk_drives
    content {
      controller_type                 = hard_disk_drivers.value["controller_type"]
      controller_number               = hard_disk_drivers.value["controller_number"]
      controller_location             = hard_disk_drivers.value["controller_location"]
      path                            = hard_disk_drivers.value["path"]
      disk_number                     = hard_disk_drivers.value["disk_number"]
      resource_pool_name              = hard_disk_drivers.value["resource_pool_name"]
      support_persistent_reservations = hard_disk_drivers.value["support_persistent_reservations"]
      maximum_iops                    = hard_disk_drivers.value["maximum_iops"]
      minimum_iops                    = hard_disk_drivers.value["minimum_iops"]
      qos_policy_id                   = hard_disk_drivers.value["qos_policy_id"]
      override_cache_attributes       = hard_disk_drivers.value["override_cache_attributes"]
    }
  }
}
