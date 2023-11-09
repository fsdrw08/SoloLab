locals {
  count = 1
}

data "ignition_disk" "podmgr" {
  device     = "/dev/sdb"
  wipe_table = false
  partition {
    number  = 1
    label   = "podmgr"
    sizemib = 0
  }
}

data "ignition_filesystem" "podmgr" {
  device          = "/dev/disk/by-partlabel/podmgr"
  format          = "xfs"
  wipe_filesystem = false
  label           = "podmgr"
  path            = "/var/home/podmgr"
}

data "ignition_directory" "podmgr" {
  path = "/var/home/podmgr"
  mode = 448 # 700 -> 448
  uid  = 1001
  gid  = 1001
}

data "ignition_user" "podmgr" {
  name           = "podmgr"
  uid            = 1001
  home_dir       = "/home/podmgr/"
  no_create_home = false
  shell          = "/bin/bash"
  password_hash  = "$y$j9T$I4IXP5reKRLKrkwuNjq071$yHlJulSZGzmyppGbdWHyFHw/D8Gl247J2J8P43UnQWA"
  # ssh_authorized_keys = [
  #   "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key"
  # ]
}

data "ignition_file" "disable_dhcp" {
  path      = "/etc/NetworkManager/conf.d/noauto.conf"
  mode      = 420
  overwrite = true
  content {
    content = <<EOT
[main]
# Do not do automatic (DHCP/SLAAC) configuration on ethernet devices
# with no other matching connections.
no-auto-default=*
EOT
  }
}

data "ignition_file" "eth0" {
  count     = local.count
  path      = "/etc/NetworkManager/system-connections/eth0.nmconnection"
  mode      = 384
  overwrite = true
  content {
    content = <<EOT
[connection]
id=eth0
type=ethernet
interface-name=eth0

[ipv4]
method=manual
addresses=192.168.255.2${count.index + 0}
gateway=192.168.255.1
dns=192.168.255.1
EOT
  }
}

data "ignition_config" "ignition" {
  count       = local.count
  disks       = [data.ignition_disk.podmgr.rendered]
  filesystems = [data.ignition_filesystem.podmgr.rendered]
  directories = [data.ignition_directory.podmgr.rendered]
  users       = [data.ignition_user.podmgr.rendered]
  files = [
    data.ignition_file.eth0[count.index].rendered,
    data.ignition_file.disable_dhcp.rendered
  ]

}

# copy ignition file to remote
resource "local_file" "ignition" {
  count    = local.count
  content  = data.ignition_config.ignition[count.index].rendered
  filename = "ignition${count.index + 1}.json"
}

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
    host     = var.hyperv_host
    user     = var.hyperv_user
    password = sensitive(var.hyperv_password)
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

resource "hyperv_vhd" "boot_disk" {
  count = local.count
  path = join("\\", [
    var.vhd_dir,
    local.count <= 1 ? "${var.vm_name}" : "${var.vm_name}${count.index + 1}",
    join("", ["${var.vm_name}", ".vhdx"])
    ]
  )
  source = var.source_disk
}

module "hyperv_machine_instance" {
  source     = "../modules/hyperv_instance"
  depends_on = [null_resource.remote]
  count      = local.count

  vm_instance = {
    name                 = local.count <= 1 ? var.vm_name : "${var.vm_name}${count.index + 1}"
    checkpoint_type      = "Disabled"
    dynamic_memory       = true
    generation           = 2
    memory_maximum_bytes = 8191475712
    memory_minimum_bytes = 2147483648
    memory_startup_bytes = 2147483648
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

    network_adaptors = [
      {
        name        = "Internal Switch"
        switch_name = "Internal Switch"
      }
    ]

    hard_disk_drives = [
      {
        controller_type     = "Scsi"
        controller_number   = "0"
        controller_location = "0"
        path                = hyperv_vhd.boot_disk[count.index].path
        # path                = local.count <= 1 ? hyperv_vhd.boot_disk.path : hyperv_vhd.boot_disk[count.index].path
      },
      {
        controller_type     = "Scsi"
        controller_number   = "0"
        controller_location = "1"
        path                = local.count <= 1 ? var.data_disk_path : var.data_disk_path[count.index]
      }
    ]
  }
}

resource "null_resource" "kvpctl" {
  depends_on = [module.hyperv_machine_instance]
  count      = local.count

  triggers = {
    # https://discuss.hashicorp.com/t/terraform-null-resources-does-not-detect-changes-i-have-to-manually-do-taint-to-recreate-it/23443/3
    manifest_sha1 = sha1(jsonencode(data.ignition_config.ignition[count.index].rendered))
    vhd_dir       = var.vhd_dir
    vm_name       = local.count <= 1 ? "${var.vm_name}" : "${var.vm_name}${count.index + 1}"
    # https://github.com/Azure/caf-terraform-landingzones/blob/a54831d73c394be88508717677ed75ea9c0c535b/caf_solution/add-ons/terraform_cloud/terraform_cloud.tf#L2
    filename = local_file.ignition[count.index].filename
    host     = var.hyperv_host
    user     = var.hyperv_user
    password = sensitive(var.hyperv_password)
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
      Powershell -Command "$ignitionFile=(Join-Path -Path '${self.triggers.vhd_dir}' -ChildPath '${self.triggers.vm_name}\${self.triggers.filename}'); kvpctl.exe ${var.vm_name} add-ign $ignitionFile"
    EOT
    ]
  }
}
