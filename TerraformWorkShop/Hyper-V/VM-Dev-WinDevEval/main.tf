locals {
  vhd_dir = "C:\\ProgramData\\Microsoft\\Windows\\Virtual Hard Disks"
  boot_disk_path = join("\\", [
    var.vhd_dir,
    var.vm_name,
    element(split("\\", var.source_disk), length(split("\\", var.source_disk)) - 1)
    ]
  )
}

module "cloudinit_nocloud_iso" {
  count    = var.cloudinit_nocloud == null ? 0 : 1
  source   = "../modules/cloudinit_nocloud_iso3"
  iso_name = "cloud-init"
  files    = null
  destination_iso_file_path = join("\\", [
    var.vhd_dir,
    "${var.vm_name}\\cloudinit.iso"
    ]
  )
}

data "terraform_remote_state" "data_disk" {
  count   = var.data_disk_ref == null ? 0 : 1
  backend = "local"
  config = {
    path = "${path.module}/${var.data_disk_ref}"
  }
}

module "hyperv_machine_instance" {
  source = "../modules/hyperv_instance2"
  depends_on = [
    module.cloudinit_nocloud_iso,
  ]

  boot_disk = {
    path   = local.boot_disk_path
    source = var.source_disk
  }

  boot_disk_drive = [
    {
      controller_type     = "Scsi"
      controller_number   = "0"
      controller_location = "0"
      path                = local.boot_disk_path
    }
  ]

  additional_disk_drives = var.data_disk_ref == null ? [] : [
    {
      controller_type     = "Scsi"
      controller_number   = "0"
      controller_location = "2"
      path                = data.terraform_remote_state.data_disk[0].outputs.path
    }
  ]

  vm_instance = {
    name                 = var.vm_name
    checkpoint_type      = var.checkpoint_type
    static_memory        = true
    generation           = 2
    memory_maximum_bytes = var.memory_maximum_bytes
    memory_minimum_bytes = var.memory_minimum_bytes
    memory_startup_bytes = var.memory_startup_bytes
    notes                = "This VM instance is managed by terraform"
    processor_count      = 4
    state                = "Running"

    vm_firmware = {
      console_mode                    = "Default"
      enable_secure_boot              = var.enable_secure_boot
      secure_boot_template            = "MicrosoftUEFICertificateAuthority"
      pause_after_boot_failure        = "Off"
      preferred_network_boot_protocol = "IPv4"
      boot_order = [
        {
          boot_type           = "HardDiskDrive"
          controller_number   = "0"
          controller_location = "0"
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

    integration_services = {
      "Guest Service Interface" = true
      "Heartbeat"               = true
      "Key-Value Pair Exchange" = true
      "Shutdown"                = true
      "Time Synchronization"    = true
      "VSS"                     = true
    }

    network_adaptors = var.network_adaptors

    dvd_drives = var.cloudinit_nocloud == null ? null : [
      {
        controller_number   = 0
        controller_location = 1
        path                = "${module.cloudinit_nocloud_iso.resolve_destination_iso_file_path}"
        # path = local.count <= 1 ? join("\\", [
        #   "${var.vhd_dir}",
        #   "${var.vm_name}",
        #   "${module.cloudinit_nocloud_iso[count.index].isoName}"
        #   ]) : join("\\", [
        #   "${var.vhd_dir}",
        #   "${var.vm_name}${count.index + 1}",
        #   "${module.cloudinit_nocloud_iso[count.index].isoName}"
        # ])
      }
    ]

  }
}
