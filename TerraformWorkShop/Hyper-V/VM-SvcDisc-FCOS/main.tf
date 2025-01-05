locals {
  count = 1
}

data "ct_config" "ignition" {
  count        = local.count
  content      = templatefile(var.butane.files.base, var.butane.vars)
  strict       = true
  pretty_print = false

  snippets = [
    for file in var.butane.files.others :
    templatefile(file, var.butane.vars)
  ]
}

# present ignition file to local
resource "local_file" "ignition" {
  count    = local.count
  content  = data.ct_config.ignition[count.index].rendered
  filename = "ignition${count.index + 1}.json"
}

# copy ignition file to remote
resource "null_resource" "remote" {
  count      = local.count
  depends_on = [local_file.ignition]
  triggers = {
    # https://discuss.hashicorp.com/t/terraform-null-resources-does-not-detect-changes-i-have-to-manually-do-taint-to-recreate-it/23443/3
    manifest_sha1 = sha1(jsonencode(data.ct_config.ignition[count.index].rendered))
    vhd_dir       = var.vm.vhd.dir
    vm_name       = local.count <= 1 ? "${var.vm.name}" : "${var.vm.name}${count.index + 1}"
    # https://github.com/Azure/caf-terraform-landingzones/blob/a54831d73c394be88508717677ed75ea9c0c535b/caf_solution/add-ons/terraform_cloud/terraform_cloud.tf#L2
    filename = local_file.ignition[count.index].filename
    host     = var.prov_hyperv.host
    user     = var.prov_hyperv.user
    password = sensitive(var.prov_hyperv.password)
  }

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
  # copy to remote
  provisioner "file" {
    source = local_file.ignition[count.index].filename
    # destination = "C:\\ProgramData\\Microsoft\\Windows\\Virtual Hard Disks\\${each.key}\\cloud-init.iso"
    destination = join("/", [
      "${self.triggers.vhd_dir}",
      "${self.triggers.vm_name}\\${self.triggers.filename}"
      ]
    )
  }

  # for destroy
  provisioner "remote-exec" {
    when = destroy
    inline = [<<-EOT
      Powershell -Command "$ignition_file=(Join-Path -Path '${self.triggers.vhd_dir}' -ChildPath '${self.triggers.vm_name}\${self.triggers.filename}'); if (Test-Path $ignition_file) { Remove-Item $ignition_file }"
    EOT
    ]
  }
}

data "terraform_remote_state" "data_disk" {
  backend = var.vm.vhd.data_disk_ref.backend
  config  = var.vm.vhd.data_disk_ref.config
}

resource "terraform_data" "boot_disk" {
  count = local.count
  input = join("\\", [
    var.vm.vhd.dir,
    local.count <= 1 ? "${var.vm.name}" : "${var.vm.name}${count.index + 1}",
    join(".", [
      "boot",
      element(
        split(".", basename(var.vm.vhd.source)),
      length(split(".", basename(var.vm.vhd.source))) - 1)
    ])
    ]
  )
}

module "hyperv_machine_instance" {
  source     = "../modules/hyperv_instance2"
  depends_on = [null_resource.remote]
  count      = local.count

  boot_disk = {
    path   = terraform_data.boot_disk[count.index].input
    source = var.vm.vhd.source
  }

  boot_disk_drive = [
    {
      controller_type     = "Scsi"
      controller_number   = "0"
      controller_location = "0"
      path                = terraform_data.boot_disk[count.index].input
    }
  ]

  additional_disk_drives = [
    {
      controller_type     = "Scsi"
      controller_number   = "0"
      controller_location = "2"
      path                = local.count <= 1 ? data.terraform_remote_state.data_disk.outputs.path : data.terraform_remote_state.data_disk.outputs.path[count.index]
    }
  ]

  vm_instance = {
    name                 = local.count <= 1 ? var.vm.name : "${var.vm.name}${count.index + 1}"
    checkpoint_type      = "Disabled"
    dynamic_memory       = true
    generation           = 2
    memory_maximum_bytes = var.vm.memory.maximum_bytes
    memory_minimum_bytes = var.vm.memory.minimum_bytes
    memory_startup_bytes = var.vm.memory.startup_bytes
    notes                = "This VM instance is managed by terraform"
    processor_count      = 4
    state                = "Off"

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

  }
}

# execute kvpctl to put ignition file content to hyper-v kv
resource "null_resource" "kvpctl" {
  depends_on = [
    module.hyperv_machine_instance,
    null_resource.remote
  ]
  count = local.count

  triggers = {
    # https://discuss.hashicorp.com/t/terraform-null-resources-does-not-detect-changes-i-have-to-manually-do-taint-to-recreate-it/23443/3
    manifest_sha1 = sha1(jsonencode(data.ct_config.ignition[count.index].rendered))
    vhd_dir       = var.vm.vhd.dir
    vm_name       = local.count <= 1 ? "${var.vm.name}" : "${var.vm.name}${count.index + 1}"
    # https://github.com/Azure/caf-terraform-landingzones/blob/a54831d73c394be88508717677ed75ea9c0c535b/caf_solution/add-ons/terraform_cloud/terraform_cloud.tf#L2
    filename = local_file.ignition[count.index].filename
    host     = var.prov_hyperv.host
    user     = var.prov_hyperv.user
    password = sensitive(var.prov_hyperv.password)
  }

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

  provisioner "remote-exec" {
    inline = [<<-EOT
      Powershell -Command "$ignitionFile=(Join-Path -Path '${var.vm.vhd.dir}' -ChildPath '${self.triggers.vm_name}\${self.triggers.filename}'); kvpctl.exe ${self.triggers.vm_name} add-ign $ignitionFile"
    EOT
    ]
  }
}

resource "powerdns_record" "record" {
  zone    = var.dns_record.zone
  name    = var.dns_record.name
  type    = var.dns_record.type
  ttl     = var.dns_record.ttl
  records = var.dns_record.records
}
