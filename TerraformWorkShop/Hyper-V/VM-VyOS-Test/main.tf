locals {
  count   = "1"
  vm_name = var.vm_name
  boot_disk_path = join("\\", [
    var.vhd_dir,
    var.vm_name,
    element(split("\\", var.source_disk), length(split("\\", var.source_disk)) - 1)
    ]
  )
}

data "terraform_remote_state" "data_disk" {
  backend = "local"
  config = {
    path = "${path.module}/${var.data_disk_ref}"
  }
}


# https://stackoverflow.com/questions/68577948/terraform-local-file-dependency-with-null-resource-resulting-in-no-such-file-o
# https://stackoverflow.com/questions/51138667/can-terraform-watch-a-directory-for-changes
module "cloudinit_nocloud_iso" {
  source = "../modules/cloudinit_nocloud_iso2"
  count  = local.count
  cloudinit_config = {
    isoName = local.count <= 1 ? "cloud-init.iso" : "cloud-init${count.index + 1}.iso"
    part = [
      {
        filename = "meta-data"
        content  = <<-EOT
        instance-id: iid-infrasvc-CetnOS_20230614
        local-hostname: InfraSvc-CetnOS
        EOT
      },
      {
        filename = "user-data"
        content  = <<-EOT
        #cloud-config
        # https://github.com/ahpnils/lab-as-code/blob/be47a0d8aabf66b38f718de35546411eb60c879b/cloud-init/isp1router1/user-data#L4
        # https://docs.vyos.io/en/stable/automation/cloud-init.html
        # !!! one command per line
        # !!! if command ends in a value, it must be inside single quotes
        # !!! a single-quote symbol is not allowed inside command or value
        # to debug, refer
        # https://forum.vyos.io/t/errors-when-trying-to-upgrade-a-working-configuration-from-1-2-5-to-1-3-rolling-lastest-build/5395/6
        vyos_config_commands:
          # Interface
          - set interfaces ethernet eth0 address 'dhcp'
          - set interfaces ethernet eth0 description 'WAN'
          - set interfaces ethernet eth1 address '192.168.255.1/24'
          - set interfaces ethernet eth1 description 'LAN'
          # Service
          # DHCP server for local network
          - set service dhcp-server shared-network-name LAN subnet 192.168.255.0/24 range 0 start '192.168.255.100'
          - set service dhcp-server shared-network-name LAN subnet 192.168.255.0/24 range 0 stop '192.168.255.200'
          - set service dhcp-server shared-network-name LAN subnet 192.168.255.0/24 name-server '192.168.255.1'
          - set service dhcp-server shared-network-name LAN subnet 192.168.255.0/24 default-router '192.168.255.1'
          - set service dhcp-server shared-network-name LAN subnet 192.168.255.0/24 domain-name 'sololab'
          - set service dhcp-server shared-network-name LAN authoritative
          - set service dhcp-server shared-network-name LAN ping-check
          - set service dhcp-server hostfile-update
          - set service dhcp-server host-decl-name
          # DNS
          - set service dns forwarding cache-size '0'
          - set service dns forwarding listen-address '192.168.255.1'
          - set service dns forwarding allow-from '192.168.255.0/24'
          - set service dns forwarding name-server '223.5.5.5'
          - set service dns forwarding name-server '223.6.6.6'
          # ssh
          - set service ssh port '22'
          # System
          # hostname
          - set system host-name 'vyos-lts'
          # auth config
          - set system login user vagrant authentication plaintext-password 'vagrant'
          - set system login user vagrant authentication public-keys vagrant key 'AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ=='
          - set system login user vagrant authentication public-keys vagrant type 'ssh-rsa'
          # name server
          - set system name-server '192.168.255.1'
          # ntp
          - set system ntp server 'cn.ntp.org.cn'
          # timezone
          - set system time-zone 'Asia/Shanghai'

        write_files:
          - path: /opt/vyatta/etc/config/scripts/vyos-preconfig-bootup.script
            owner: root:vyattacfg
            permissions: "0775"
            content: |
              #!/usr/bin/bash
              # Check if disk exists
              # https://linuxize.com/post/regular-expressions-in-grep/
              if ! lsblk | grep '^sdb.*disk'; then
                echo "Disk /dev/sdb not found"
                exit 1
              fi

              # Check if GPT partition table exists
              partition_table=$(parted /dev/sdb print | grep 'Partition Table:')
              if [[ $partition_table != *gpt* ]]; then
                echo "Creating GPT partition table on /dev/sdb"
                sgdisk -g /dev/sdb
              fi

              # Check if data partition exists
              if lsblk | grep 'sdb1.*part'; then
                echo "Partition /dev/sdb1 already exists"
              else
                echo "Creating data partition on /dev/sdb"
                sgdisk -n 1 /dev/sdb
              fi

              # Check if file system exists
              if ! lsblk -f | grep 'sdb1.*ext4'; then
                echo "Creating ext4 file system on /dev/sdb1"
                mkfs.ext4 /dev/sdb1
              fi

              # Check if label exists
              if ! sudo blkid -s LABEL -o value /dev/sdb; then
                echo "Labeling /dev/sdb1 as data"
                e2label /dev/sdb1 data
              fi

              # Mount the partition on boot
              if ! grep "/dev/sdb1 /mnt/data ext4 defaults 0 2" /etc/fstab; then
                echo "Mounting /dev/sdb1 to /mnt/data on boot"
                echo "/dev/sdb1 /mnt/data ext4 defaults 0 2" >> /etc/fstab
              fi

              # Create mount point if it doesn't exist
              if [ ! -d "/mnt/data" ]; then
                echo "Creating /mnt/data directory"
                mkdir -p /mnt/data
              fi

              # Mount the partition manually
              # https://man7.org/linux/man-pages/man8/mount.8.html
              if ! mountpoint -q /mnt/data; then
                echo "Mounting /dev/sdb1 to /mnt/data"
                mount /mnt/data
              fi

              echo "Disk configuration complete"

          # config after clash setup
          - path: /tmp/finalConfig.sh
            owner: root:vyattacfg
            permissions: "0775"
            content: |
              #!/bin/vbash
              # Ensure that we have the correct group or we'll corrupt the configuration
              if [ "$(id -g -n)" != 'vyattacfg' ] ; then
                  exec sg vyattacfg -c "/bin/vbash $(readlink -f $0) $@"
              fi
              source /opt/vyatta/etc/functions/script-template
              configure
              set nat destination rule 10 description 'CLASH FORWARD'
              set nat destination rule 10 inbound-interface 'eth1'
              set nat destination rule 10 protocol 'tcp_udp'
              set nat destination rule 10 destination port '80,443'
              set nat destination rule 10 source address '192.168.255.0/24'
              set nat destination rule 10 translation address '192.168.255.1'
              set nat destination rule 10 translation port '7892'
              commit
              save
              exit

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
    vhd_dir       = var.vhd_dir
    vm_name       = local.count <= 1 ? "${var.vm_name}" : "${var.vm_name}${count.index + 1}"
    # https://github.com/Azure/caf-terraform-landingzones/blob/a54831d73c394be88508717677ed75ea9c0c535b/caf_solution/add-ons/terraform_cloud/terraform_cloud.tf#L2
    isoName  = module.cloudinit_nocloud_iso[count.index].isoName
    host     = var.host
    user     = var.user
    password = sensitive(var.password)
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
    destination = join("/", [
      "${self.triggers.vhd_dir}",
      "${self.triggers.vm_name}\\${self.triggers.isoName}"
      ]
    )
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
  source     = "../modules/hyperv_instance2"
  depends_on = [null_resource.remote]
  count      = local.count

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

  additional_disk_drives = [
    {
      controller_type     = "Scsi"
      controller_number   = "0"
      controller_location = "2"
      path                = data.terraform_remote_state.data_disk.outputs.path
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
        path                = local.count <= 1 ? join("\\", ["${var.vhd_dir}", "${var.vm_name}", "${module.cloudinit_nocloud_iso[count.index].isoName}"]) : join("\\", ["${var.vhd_dir}", "${var.vm_name}${count.index + 1}", "${module.cloudinit_nocloud_iso[count.index].isoName}"])
      }
    ]

  }
}
