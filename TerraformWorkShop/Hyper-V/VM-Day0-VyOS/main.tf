# data "terraform_remote_state" "root_ca" {
#   backend = "local"
#   config = {
#     path = "../../TLS/RootCA/terraform.tfstate"
#   }
# }

# load secret from vault
locals {
  secrets_vault_kvv2 = flatten([
    for value_refer in var.cloudinit.vars.value_refers == null ? [] : var.cloudinit.vars.value_refers : {
      mount = value_refer.vault_kvv2.mount
      name  = value_refer.vault_kvv2.name
    }
    if value_refer.vault_kvv2 != null
  ])
  secret_var_keys = flatten([
    for value_refer in var.cloudinit.vars.value_refers == null ? [] : var.cloudinit.vars.value_refers : [
      for value_set in value_refer.value_sets : [
        value_set.name
      ]
    ]
    # if value_refer.vault_kvv2 != null
    if value_refer.tfstate != null
  ])
  tls_tfstate = flatten([
    for value_refer in var.cloudinit.vars.value_refers == null ? [] : var.cloudinit.vars.value_refers : {
      backend = value_refer.tfstate.backend
      name    = value_refer.tfstate.cert_name
    }
    if value_refer.tfstate != null
  ])
}

# load cert from local tls
data "terraform_remote_state" "tfstate" {
  for_each = local.tls_tfstate == null ? null : {
    for tls_tfstate in local.tls_tfstate : tls_tfstate.name => tls_tfstate
  }
  backend = each.value.backend.type
  config  = each.value.backend.config
}

locals {
  cert_list = data.terraform_remote_state.tfstate == null ? null : flatten([
    for value_refer in var.cloudinit.vars.value_refers == null ? [] : var.cloudinit.vars.value_refers : [
      for cert in data.terraform_remote_state.tfstate[value_refer.tfstate.cert_name].outputs.vyos_certs : cert
      if cert.name == value_refer.tfstate.cert_name
    ]
    if value_refer.tfstate != null
  ])
  certs = data.terraform_remote_state.tfstate == null ? null : {
    for cert in local.cert_list : cert.name => cert
  }
  secret_var_values = flatten([
    for value_refer in var.cloudinit.vars.value_refers == null ? [] : var.cloudinit.vars.value_refers : [
      for value_set in value_refer.value_sets : [
        # data.vault_kv_secret_v2.secret[value_refer.vault_kvv2.name].data[value_set.value_ref_key]
        local.certs[value_refer.tfstate.cert_name][value_set.value_ref_key]
      ]
    ]
    # if value_refer.vault_kvv2 != null
    if value_refer.tfstate != null
  ])
}


# for debug
output "local_certs" {
  value = local.certs
}
output "local_secret_var_values" {
  value = local.secret_var_values
}


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
  count    = var.vm.count == null ? 0 : var.vm.count
  iso_name = "cloud-init-${local.vm_names[count.index]}"
  files = [
    for file in var.cloudinit.files : {
      content = templatefile(
        file,
        merge(
          var.cloudinit.vars.global,
          var.cloudinit.vars.local[count.index],
          zipmap(local.secret_var_keys, local.secret_var_values)
        )
      )
      filename = basename(file)
    }
  ]
  destination_iso_file_path = join("\\", [
    var.vm.vhd.dir,
    "${local.vm_names[count.index]}\\cloudinit.iso"
    ]
  )
}

locals {
  vm_names = var.vm.count == 1 ? [var.vm.base_name] : [
    for count in range(var.vm.count) : "${var.vm.base_name}0${count + 1}"
  ]
  data_disks = var.vm.vhd.data_disk_tfstate == null ? null : var.vm.count == 1 ? flatten([
    for vhd in data.terraform_remote_state.data_disk[0].outputs.vhds : vhd.path
    # if replace(vhd.name, "/\\..*/", "") == var.vm.base_name
    if regex("^[^.]+", vhd.name) == var.vm.base_name
    ]) : flatten([
    for count in range(var.vm.count) : [
      for vhd in data.terraform_remote_state.data_disk[0].outputs.vhds : vhd.path
      if startswith(vhd.name, "${var.vm.base_name}0${count + 1}")
    ]
  ])
}

# fetch data disk info
data "terraform_remote_state" "data_disk" {
  count   = var.vm.vhd.data_disk_tfstate == null ? 0 : 1
  backend = var.vm.vhd.data_disk_tfstate.backend.type
  config  = var.vm.vhd.data_disk_tfstate.backend.config
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

  additional_disk_drives = var.vm.vhd.data_disk_tfstate == null ? null : [
    {
      controller_type     = "Scsi"
      controller_number   = "0"
      controller_location = "2"
      path                = var.vm.count <= 1 ? one(local.data_disks) : local.data_disks[count.index]
    }
  ]

  vm_instance = {
    name                 = local.vm_names[count.index]
    checkpoint_type      = var.vm.checkpoint_type
    static_memory        = var.vm.memory.static
    dynamic_memory       = var.vm.memory.dynamic
    generation           = 2
    memory_maximum_bytes = var.vm.memory.maximum_bytes
    memory_minimum_bytes = var.vm.memory.minimum_bytes
    memory_startup_bytes = var.vm.memory.startup_bytes
    notes                = "This VM instance is managed by terraform"
    processor_count      = var.vm.processor_count
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

