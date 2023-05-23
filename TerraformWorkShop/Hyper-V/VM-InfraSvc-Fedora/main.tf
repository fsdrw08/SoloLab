locals {
  vhd_dir = "C:\\ProgramData\\Microsoft\\Windows\\Virtual Hard Disks\\InfraSvc-Fedora38\\"
}

resource "hyperv_vhd" "InfraSvc-Fedora38" {
  # path   = "C:\\ProgramData\\Microsoft\\Windows\\Virtual Hard Disks\\InfraSvc-Fedora38\\InfraSvc-Fedora38.vhdx"
  path   = join("", [local.vhd_dir, "InfraSvc-Fedora38.vhdx"])
  source = "C:\\ProgramData\\Microsoft\\Windows\\Virtual Hard Disks\\output-fedora38-base\\Virtual Hard Disks\\packer-fedora38-g2.vhdx"
}

data "terraform_remote_state" "InfraSvc-Data" {
  backend = "local"
  config = {
    path = "${path.module}/../Disk-InfraSvc-Data/terraform.tfstate"
  }
}

# https://stackoverflow.com/questions/68577948/terraform-local-file-dependency-with-null-resource-resulting-in-no-such-file-o
# https://stackoverflow.com/questions/51138667/can-terraform-watch-a-directory-for-changes
# https://github.com/Venafi/terraform-provider-venafi/blob/21f5b40cb5d07202607f4e09581d0243e06d5650/examples/microsoft_iis/iis.tf#L1
resource "null_resource" "cloud-init" {
  triggers = {
    cloudinit_iso = fileexists("./cloud-init.iso") ? "1" : uuid()
    dir_sha1      = sha1(join("", [for f in fileset(".", "./cloud-init/*") : filesha1(f)]))
    host          = var.host
    user          = var.user
    password      = sensitive(var.password)
    vhd_dir       = local.vhd_dir
  }

  #for create
  provisioner "local-exec" {
    command = "oscdimg.exe ${abspath(path.module)}/cloud-init ${abspath(path.module)}/cloud-init.iso -j2 -lcidata"
  }

  provisioner "file" {
    source      = "./cloud-init.iso"
    destination = "C:\\ProgramData\\Microsoft\\Windows\\Virtual Hard Disks\\InfraSvc-Fedora38\\cloud-init.iso"

    connection {
      type     = "winrm"
      host     = self.triggers.host
      user     = self.triggers.user
      password = self.triggers.password
      use_ntlm = true
      https    = true
      insecure = true
      timeout  = "20s"
    }
  }

  # for destroy
  provisioner "local-exec" {
    when        = destroy
    command     = <<-EOT
      if (Test-Path ${abspath(path.module)}/cloud-init.iso) {
        Remove-Item ${abspath(path.module)}/cloud-init.iso
      }
    EOT
    interpreter = ["Powershell", "-Command"]
  }

  provisioner "remote-exec" {
    when = destroy
    inline = [<<-EOT
      Powershell -Command "$cloudinit_iso=(Join-Path -Path '${self.triggers.vhd_dir}' -ChildPath 'cloud-init.iso'); if (Test-Path $cloudinit_iso) { Remove-Item $cloudinit_iso }"
    EOT
    ]

    connection {
      type     = "winrm"
      host     = self.triggers.host
      user     = self.triggers.user
      password = self.triggers.password
      use_ntlm = true
      https    = true
      insecure = true
      timeout  = "20s"
    }
  }
}

resource "hyperv_machine_instance" "InfraSvc-Fedora38" {
  name       = "InfraSvc-Fedora38"
  generation = 2
  #   automatic_critical_error_action         = "Pause"
  #   automatic_critical_error_action_timeout = 30
  #   automatic_start_action                  = "StartIfRunning"
  #   automatic_start_delay                   = 0
  #   automatic_stop_action                   = "Save"
  checkpoint_type = "Disabled"
  #   guest_controlled_cache_types            = false
  #   high_memory_mapped_io_space             = 536870912
  #   low_memory_mapped_io_space              = 134217728
  #   lock_on_disconnect                      = "Off"
  memory_maximum_bytes = 4095737856
  memory_minimum_bytes = 2147483648
  memory_startup_bytes = 2147483648
  notes                = "This VM instance is managed by terraform"
  processor_count      = 4
  #   smart_paging_file_path = "C:/ProgramData/Microsoft/Windows/Hyper-V"
  #   snapshot_file_location = "C:/ProgramData/Microsoft/Windows/Hyper-V"
  dynamic_memory = true
  #   static_memory  = false
  state = "Running"

  # Configure firmware
  vm_firmware {
    console_mode                    = "Default"
    enable_secure_boot              = "On"
    secure_boot_template            = "MicrosoftUEFICertificateAuthority"
    pause_after_boot_failure        = "Off"
    preferred_network_boot_protocol = "IPv4"
    boot_order {
      boot_type           = "HardDiskDrive"
      controller_number   = "0"
      controller_location = "0"
    }
  }

  # Configure processor
  vm_processor {
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

  # Configure integration services
  integration_services = {
    "Guest Service Interface" = true
    "Heartbeat"               = true
    "Key-Value Pair Exchange" = true
    "Shutdown"                = true
    "Time Synchronization"    = true
    "VSS"                     = true
  }

  # Create a network adaptor
  network_adaptors {
    name        = "Internal Switch"
    switch_name = "Internal Switch"
    # management_os                              = false
    # is_legacy                                  = false
    # dynamic_mac_address                        = true
    # static_mac_address                         = ""
    # mac_address_spoofing                       = "Off"
    # dhcp_guard                                 = "Off"
    # router_guard                               = "Off"
    # port_mirroring                             = "None"
    # ieee_priority_tag                          = "Off"
    # vmq_weight                                 = 100
    # iov_queue_pairs_requested                  = 1
    # iov_interrupt_moderation                   = "Off"
    # iov_weight                                 = 100
    # ipsec_offload_maximum_security_association = 512
    # maximum_bandwidth                          = 0
    # minimum_bandwidth_absolute                 = 0
    # minimum_bandwidth_weight                   = 0
    # mandatory_feature_id                       = []
    # resource_pool_name                         = ""
    # test_replica_pool_name                     = ""
    # test_replica_switch_name                   = ""
    # virtual_subnet_id                          = 0
    # allow_teaming                              = "On"
    # not_monitored_in_cluster                   = false
    # storm_limit                                = 0
    # dynamic_ip_address_limit                   = 0
    # device_naming                              = "Off"
    # fix_speed_10g                              = "Off"
    # packet_direct_num_procs                    = 0
    # packet_direct_moderation_count             = 0
    # packet_direct_moderation_interval          = 0
    # vrss_enabled                               = true
    # vmmq_enabled                               = false
    # vmmq_queue_pairs                           = 16
  }

  # Create dvd drive
  dvd_drives {
    controller_number   = "0"
    controller_location = "1"
    # https://developer.hashicorp.com/terraform/language/functions/abspath
    # https://developer.hashicorp.com/terraform/language/functions/replace
    # path               = "C:\\ProgramData\\Microsoft\\Windows\\Virtual Hard Disks\\InfraSvc-Fedora38\\cloud-init.iso"
    path               = join("", [local.vhd_dir, "cloud-init.iso"])
    resource_pool_name = "Primordial" # default value
  }
  # Create a hard disk drive
  hard_disk_drives {
    controller_type     = "Scsi"
    controller_number   = "0"
    controller_location = "0"
    path                = hyperv_vhd.InfraSvc-Fedora38.path
    # disk_number                     = 4294967295
    # resource_pool_name              = "Primordial"
    # support_persistent_reservations = false
    # maximum_iops                    = 0
    # minimum_iops                    = 0
    # qos_policy_id                   = "00000000-0000-0000-0000-000000000000"
    # override_cache_attributes       = "Default"
  }

  hard_disk_drives {
    controller_type     = "Scsi"
    controller_number   = "0"
    controller_location = "2"
    path                = data.terraform_remote_state.InfraSvc-Data.outputs.path
    # disk_number                     = 4294967295
    # resource_pool_name              = "Primordial"
    # support_persistent_reservations = false
    # maximum_iops                    = 0
    # minimum_iops                    = 0
    # qos_policy_id                   = "00000000-0000-0000-0000-000000000000"
    # override_cache_attributes       = "Default"
  }
}
