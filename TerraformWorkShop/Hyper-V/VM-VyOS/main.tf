data "terraform_remote_state" "root_ca" {
  backend = "local"
  config = {
    path = "../../TLS/RootCA/terraform.tfstate"
  }
}

locals {
  vm_names = var.vm.count == 1 ? [var.vm.base_name] : [
    for count in range(var.vm.count) : "${var.vm.base_name}0${count + 1}"
  ]
  cert = [
    for cert in data.terraform_remote_state.root_ca.outputs.signed_certs : cert
    if cert.name == "vyos"
  ]
}

# for debug
# output "int_ca_pem" {
#   value = join("",
#     slice(
#       split("\n", data.terraform_remote_state.root_ca.outputs.int_ca_pem),
#       1,
#       length(
#         split("\n", data.terraform_remote_state.root_ca.outputs.int_ca_pem)
#       ) - 2
#     )
#   )
# }


# output "vyos_cert" {
#   value = join("",
#     slice(
#       split("\n", lookup(data.terraform_remote_state.root_ca.outputs.signed_cert_pem, "vyos", null)),
#       1,
#       length(
#         split("\n", lookup(data.terraform_remote_state.root_ca.outputs.signed_cert_pem, "vyos", null))
#       ) - 2
#     )
#   )
# }

# output "vyos_key" {
#   value = join("",
#     slice(
#       split("\n", lookup(data.terraform_remote_state.root_ca.outputs.signed_key_pkcs8, "vyos", null)),
#       1,
#       length(
#         split("\n", lookup(data.terraform_remote_state.root_ca.outputs.signed_key_pkcs8, "vyos", null))
#       ) - 2
#     )
#   )
#   # value = lookup(data.terraform_remote_state.root_ca.outputs.signed_key_pkcs8, "vyos", null)
# }

module "cloudinit_nocloud_iso" {
  source   = "../../modules/hyperv-cloudinit-nocloud"
  count    = var.vm.count
  iso_name = "cloud-init-${local.vm_names[count.index]}"
  files = [
    for content in var.cloudinit_nocloud : {
      content = templatefile(content.content_source, merge(content.content_vars,
        {
          ca_cert = join("",
            slice(
              split("\n", data.terraform_remote_state.root_ca.outputs.int_ca_pem),
              1,
              length(
                split("\n", data.terraform_remote_state.root_ca.outputs.int_ca_pem)
              ) - 2
            )
          )
          root_ca = data.terraform_remote_state.root_ca.outputs.root_cert_pem
          vyos_cert = join("",
            slice(
              split("\n", local.cert.0["cert_pem"]),
              1,
              length(
                split("\n", local.cert.0["cert_pem"])
              ) - 2
            )
          )

          vyos_key = join("",
            slice(
              split("\n", local.cert.0["key_pkcs8"]),
              1,
              length(
                split("\n", local.cert.0["key_pkcs8"])
              ) - 2
            )
          )
        }
      ))
      filename = content.filename
    }
  ]
  destination_iso_file_path = join("\\", [
    var.vm.vhd.dir,
    "${local.vm_names[count.index]}\\cloudinit.iso"
    ]
  )
}

# fetch data disk info
data "terraform_remote_state" "data_disk" {
  count   = var.vm.vhd.data_disk_ref == null ? 0 : 1
  backend = var.vm.vhd.data_disk_ref.backend
  config  = var.vm.vhd.data_disk_ref.config
}

# prepare boot disk path
resource "terraform_data" "boot_disk" {
  count = var.vm.count
  input = join("\\", [
    var.vm.vhd.dir,
    local.vm_names[count.index],
    join(".", [
      "boot",
      element(
        split(".", basename(var.vm.vhd.source)),
        length(split(".", basename(var.vm.vhd.source))) - 1
      )
    ])
    ]
  )
}

# vm instance
module "hyperv_machine_instance" {
  source     = "../../modules/hyperv-vm"
  depends_on = [module.cloudinit_nocloud_iso]
  count      = var.vm.count

  boot_disk = {
    path   = terraform_data.boot_disk[count.index].input
    source = var.vm.vhd.source
  }

  boot_disk_drive = {
    controller_type     = "Scsi"
    controller_number   = "0"
    controller_location = "0"
    path                = terraform_data.boot_disk[count.index].input
  }

  additional_disk_drives = var.vm.vhd.data_disk_ref == null ? null : [
    {
      controller_type     = "Scsi"
      controller_number   = "0"
      controller_location = "2"
      path                = var.vm.count <= 1 ? data.terraform_remote_state.data_disk[0].outputs.path : data.terraform_remote_state.data_disk[0].outputs.path[count.index]
    }
  ]

  vm_instance = {
    name                 = local.vm_names[count.index]
    checkpoint_type      = "Standard"
    static_memory        = var.vm.memory.static
    dynamic_memory       = var.vm.memory.dynamic
    generation           = 2
    memory_maximum_bytes = var.vm.memory.maximum_bytes
    memory_minimum_bytes = var.vm.memory.minimum_bytes
    memory_startup_bytes = var.vm.memory.startup_bytes
    notes                = "This VM instance is managed by terraform"
    processor_count      = 4
    state                = var.vm.power_state

    vm_firmware = {
      console_mode                    = "Default"
      enable_secure_boot              = var.vm.enable_secure_boot
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

    network_adaptors = var.vm.nic

    dvd_drives = [
      {
        controller_number   = 0
        controller_location = 1
        path                = "${module.cloudinit_nocloud_iso[count.index].resolve_destination_iso_file_path}"
      }
    ]

  }
}

