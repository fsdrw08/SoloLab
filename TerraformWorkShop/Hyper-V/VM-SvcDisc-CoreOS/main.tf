locals {
  count = 1
}

data "ignition_config" "ignition" {
  count       = local.count
  disks       = [data.ignition_disk.data.rendered]
  filesystems = [data.ignition_filesystem.data.rendered]
  systemd = [
    data.ignition_systemd_unit.data.rendered,
    data.ignition_systemd_unit.rpm_ostree.rendered
  ]
  directories = [
    data.ignition_directory.user_home.rendered,
    data.ignition_directory.user_config.rendered,
    data.ignition_directory.user_config_systemd.rendered,
    data.ignition_directory.user_config_systemd_user.rendered,
    data.ignition_directory.user_config_systemd_user_defaultTargetWants.rendered,
    data.ignition_directory.user_config_containers.rendered,
    data.ignition_directory.user_config_containers_systemd.rendered,
  ]
  users = [
    data.ignition_user.core.rendered,
    data.ignition_user.user.rendered
  ]
  files = [
    data.ignition_file.hostname[count.index].rendered,
    data.ignition_file.disable_dhcp.rendered,
    data.ignition_file.eth0[count.index].rendered,
    # data.ignition_file.hashicorp_repo.rendered,
    data.ignition_file.rpms.rendered,
    data.ignition_file.rootless_linger.rendered,
    data.ignition_file.rootless_podman_socket_tcp_service.rendered,
    data.ignition_file.enable_password_auth.rendered,
    data.ignition_file.sysctl_unprivileged_port.rendered,
  ]
  links = [
    data.ignition_link.timezone.rendered,
    data.ignition_link.rootless_podman_socket_unix_autostart.rendered,
    # if dont want to expose podman tcp socket, just comment below line
    # data.ignition_link.rootless_podman_socket_tcp_autostart.rendered,
  ]
}

# present ignition file to local
resource "local_file" "ignition" {
  count    = local.count
  content  = data.ignition_config.ignition[count.index].rendered
  filename = "ignition${count.index + 1}.json"
}

# copy ignition file to remote
resource "null_resource" "remote" {
  count      = local.count
  depends_on = [local_file.ignition]
  triggers = {
    # https://discuss.hashicorp.com/t/terraform-null-resources-does-not-detect-changes-i-have-to-manually-do-taint-to-recreate-it/23443/3
    manifest_sha1 = sha1(jsonencode(data.ignition_config.ignition[count.index].rendered))
    vhd_dir       = var.vhd_dir
    vm_name       = local.count <= 1 ? "${var.vm_name}" : "${var.vm_name}${count.index + 1}"
    # https://github.com/Azure/caf-terraform-landingzones/blob/a54831d73c394be88508717677ed75ea9c0c535b/caf_solution/add-ons/terraform_cloud/terraform_cloud.tf#L2
    filename = local_file.ignition[count.index].filename
    host     = var.hyperv.host
    user     = var.hyperv.user
    password = sensitive(var.hyperv.password)
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
  backend = "pg"
  config = {
    conn_str    = "postgres://terraform:terraform@192.168.255.1/tfstate"
    schema_name = "HyperV-SvcDisc-Disk-FCOS"
  }
}

resource "terraform_data" "boot_disk" {
  count = local.count
  input = join("\\", [
    var.vhd_dir,
    local.count <= 1 ? "${var.vm_name}" : "${var.vm_name}${count.index + 1}",
    join(".", [
      "boot",
      element(
        split(".", basename(var.source_disk)),
      length(split(".", basename(var.source_disk))) - 1)
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
    source = var.source_disk
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
    name                 = local.count <= 1 ? var.vm_name : "${var.vm_name}${count.index + 1}"
    checkpoint_type      = "Disabled"
    dynamic_memory       = true
    generation           = 2
    memory_maximum_bytes = var.memory_maximum_bytes
    memory_minimum_bytes = var.memory_minimum_bytes
    memory_startup_bytes = var.memory_startup_bytes
    notes                = "This VM instance is managed by terraform"
    processor_count      = 4
    state                = "Off"

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
    manifest_sha1 = sha1(jsonencode(data.ignition_config.ignition[count.index].rendered))
    vhd_dir       = var.vhd_dir
    vm_name       = local.count <= 1 ? "${var.vm_name}" : "${var.vm_name}${count.index + 1}"
    # https://github.com/Azure/caf-terraform-landingzones/blob/a54831d73c394be88508717677ed75ea9c0c535b/caf_solution/add-ons/terraform_cloud/terraform_cloud.tf#L2
    filename = local_file.ignition[count.index].filename
    host     = var.hyperv.host
    user     = var.hyperv.user
    password = sensitive(var.hyperv.password)
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
      Powershell -Command "$ignitionFile=(Join-Path -Path '${var.vhd_dir}' -ChildPath '${self.triggers.vm_name}\${self.triggers.filename}'); kvpctl.exe ${self.triggers.vm_name} add-ign $ignitionFile"
    EOT
    ]
  }
}
