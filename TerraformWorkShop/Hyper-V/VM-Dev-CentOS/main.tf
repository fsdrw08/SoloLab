locals {
  vhd_dir = "C:\\ProgramData\\Microsoft\\Windows\\Virtual Hard Disks"
  count   = var.vm_count <= 1 ? "" : var.vm_count
  boot_disk_path = join("\\", [
    var.vhd_dir,
    var.vm_name,
    element(split("\\", var.source_disk), length(split("\\", var.source_disk)) - 1)
    ]
  )
  vars = {
    null = null
  }
}

data "tls_certificate" "rootCA" {
  url          = "https://step-ca.service.consul:8443/acme/acme/directory"
  verify_chain = false
}

# create zip for iso
data "archive_file" "cloudinit" {
  count       = var.vm_count
  type        = "zip"
  output_path = "./${var.vm_name}${local.count}.zip"
  source {
    content = templatefile(var.cloudinit.meta_data.file_source, merge(local.vars, var.cloudinit.meta_data.vars,
      {
        count = local.count
      }
    ))
    filename = "meta-data"
  }
  source {
    content = templatefile(var.cloudinit.user_data.file_source, merge(local.vars, var.cloudinit.user_data.vars,
      {
        ca_cert = data.tls_certificate.rootCA.certificates[0].cert_pem
      },
      )
    )
    filename = "user-data"
  }
  source {
    content = templatefile(var.cloudinit.network_config.file_source, merge(local.vars, var.cloudinit.network_config.vars,
      {
        ip_addrs = slice(
          var.cloudinit.network_config.vars.ip_addr_list,
          count.index * var.cloudinit.network_config.vars.ip_count[0],
          (count.index + 1) * var.cloudinit.network_config.vars.ip_count[0]
        )
      },
      )
    )
    filename = "network-config"
  }
}

# only availble in v1.2.0, but v1.2.0 has a bug that not abel to create vhd
# resource "hyperv_iso_image" "cloudinit" {
#   count                     = var.vm_count
#   volume_name               = "CIDATA"
#   source_zip_file_path      = data.archive_file.cloudinit[count.index].output_path
#   source_zip_file_path_hash = data.archive_file.cloudinit[count.index].output_sha
#   iso_file_system_type      = "iso9660|joliet"
#   destination_iso_file_path = join("/", [
#     var.vhd_dir,
#     "${var.vm_name}${local.count}\\cloudinit.iso"
#     ]
#   )
# }

module "cloudinit_nocloud_iso" {
  source = "../modules/cloudinit_nocloud_iso2"
  count  = var.vm_count
  cloudinit_config = {
    isoName = var.vm_count <= 1 ? "cloud-init.iso" : "cloud-init${count.index + 1}.iso"
    part = [
      {
        content = templatefile(var.cloudinit.meta_data.file_source, merge(local.vars, var.cloudinit.meta_data.vars,
          {
            count = local.count
          }
        ))
        filename = "meta-data"
      },
      {
        content = templatefile(var.cloudinit.user_data.file_source, merge(local.vars, var.cloudinit.user_data.vars,
          {
            ca_cert = data.tls_certificate.rootCA.certificates[0].cert_pem
          },
          )
        )
        filename = "user-data"
      },
      {
        content = templatefile(var.cloudinit.network_config.file_source, merge(local.vars, var.cloudinit.network_config.vars,
          {
            ip_addrs = slice(
              var.cloudinit.network_config.vars.ip_addr_list,
              count.index * var.cloudinit.network_config.vars.ip_count[0],
              (count.index + 1) * var.cloudinit.network_config.vars.ip_count[0]
            )
          },
          )
        )
        filename = "network-config"
      }
    ]
  }
}

resource "null_resource" "remote" {
  depends_on = [module.cloudinit_nocloud_iso]
  count      = var.vm_count
  triggers = {
    # https://discuss.hashicorp.com/t/terraform-null-resources-does-not-detect-changes-i-have-to-manually-do-taint-to-recreate-it/23443/3
    manifest_sha1 = sha1(jsonencode(module.cloudinit_nocloud_iso[count.index].cloudinit_config))
    vhd_dir       = local.vhd_dir
    vm_name       = var.vm_count <= 1 ? "${var.vm_name}" : "${var.vm_name}${count.index + 1}"
    # https://github.com/Azure/caf-terraform-landingzones/blob/a54831d73c394be88508717677ed75ea9c0c535b/caf_solution/add-ons/terraform_cloud/terraform_cloud.tf#L2
    isoName  = module.cloudinit_nocloud_iso[count.index].isoName
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
    source = module.cloudinit_nocloud_iso[count.index].isoName
    # destination = "C:\\ProgramData\\Microsoft\\Windows\\Virtual Hard Disks\\${each.key}\\cloud-init.iso"
    destination = join("/", ["${self.triggers.vhd_dir}", "${self.triggers.vm_name}\\${self.triggers.isoName}"])
  }

  # for destroy
  provisioner "remote-exec" {
    when = destroy
    inline = [<<-EOT
      Powershell -Command "$cloudinit_iso=(Join-Path -Path '${self.triggers.vhd_dir}' -ChildPath '${self.triggers.vm_name}\${self.triggers.isoName}'); if (Test-Path $cloudinit_iso) { Remove-Item $cloudinit_iso }"
    EOT
    ]
  }
}

module "hyperv_machine_instance" {
  source = "../modules/hyperv_instance2"
  # depends_on = [hyperv_iso_image.cloudinit]
  depends_on = [null_resource.remote]
  count      = var.vm_count

  boot_disk = {
    path = join("\\", [
      var.vhd_dir,
      "${var.vm_name}${local.count}",
      join("", ["${var.vm_name}", ".vhdx"])
      ]
    )
    source = var.source_disk
  }

  boot_disk_drive = [
    {
      controller_type     = "Scsi"
      controller_number   = "0"
      controller_location = "0"
      path = join("\\", [
        var.vhd_dir,
        "${var.vm_name}${local.count}",
        join("", ["${var.vm_name}", ".vhdx"])
        ]
      )
    }
  ]

  vm_instance = {
    name                 = "${var.vm_name}${local.count}",
    checkpoint_type      = "Disabled"
    dynamic_memory       = true
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

    dvd_drives = [
      {
        controller_number   = 0
        controller_location = 1
        # path                = "${hyperv_iso_image.cloudinit[count.index].resolve_destination_iso_file_path}"
        path = var.vm_count <= 1 ? join("\\", [
          "${local.vhd_dir}",
          "${var.vm_name}",
          "${module.cloudinit_nocloud_iso[count.index].isoName}"
          ]) : join("\\", [
          "${local.vhd_dir}",
          "${var.vm_name}${count.index + 1}",
          "${module.cloudinit_nocloud_iso[count.index].isoName}"
        ])
      }
    ]

  }
}
