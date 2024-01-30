locals {
  vhd_dir = "C:\\ProgramData\\Microsoft\\Windows\\Virtual Hard Disks"
  vm_name = var.vm_name
  count   = "1"
}

data "tls_certificate" "rootCA" {
  url          = "https://step-ca.service.consul:8443/acme/acme/directory"
  verify_chain = false
}

module "cloudinit_nocloud_iso" {
  depends_on = [data.tls_certificate.rootCA]
  source     = "../modules/cloudinit_nocloud_iso2"
  count      = local.count
  cloudinit_config = {
    isoName = local.count <= 1 ? "cloud-init.iso" : "cloud-init${count.index + 1}.iso"
    # https://cloudinit.readthedocs.io/en/latest/reference/datasources/nocloud.html
    part = [
      {
        filename = "meta-data"
        content  = <<-EOT
        instance-id: iid-dev-CentOS_202401
        local-hostname: Dev-CentOS
        EOT
      },
      {
        filename = "user-data"
        content  = templatefile()
      },
      {
        filename = "network-config"
        # https://cloudinit.readthedocs.io/en/latest/reference/network-config.html#network-configuration-outputs
        content = <<-EOT
        version: 2
        ethernets:
          eth0:
            dhcp4: false
            addresses:
              - 192.168.255.1${count.index + 2}/255.255.255.0
            gateway4: 192.168.255.1
            nameservers:
              addresses: 192.168.255.1
        EOT
      }
    ]
  }
}


resource "null_resource" "remote" {
  depends_on = [module.cloudinit_nocloud_iso]
  count      = local.count
  triggers = {
    # https://discuss.hashicorp.com/t/terraform-null-resources-does-not-detect-changes-i-have-to-manually-do-taint-to-recreate-it/23443/3
    manifest_sha1 = sha1(jsonencode(module.cloudinit_nocloud_iso[count.index].cloudinit_config))
    vhd_dir       = local.vhd_dir
    vm_name       = local.count <= 1 ? "${var.vm_name}" : "${var.vm_name}${count.index + 1}"
    # https://github.com/Azure/caf-terraform-landingzones/blob/a54831d73c394be88508717677ed75ea9c0c535b/caf_solution/add-ons/terraform_cloud/terraform_cloud.tf#L2
    isoName  = module.cloudinit_nocloud_iso[count.index].isoName
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

resource "hyperv_vhd" "boot_disk" {
  path = join("\\", [
    local.vhd_dir,
    var.vm_name,
    element(split("\\", var.source_disk), length(split("\\", var.source_disk)) - 1)
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

    dvd_drives = [
      {
        controller_number   = 0
        controller_location = 1
        path = local.count <= 1 ? join("\\", [
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

    hard_disk_drives = [
      {
        controller_type     = "Scsi"
        controller_number   = "0"
        controller_location = "0"
        path                = hyperv_vhd.boot_disk.path
      },
    ]
  }
}
