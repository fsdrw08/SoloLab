locals {
  vhd_dir = "C:\\ProgramData\\Microsoft\\Windows\\Virtual Hard Disks"
  vm_name = var.vm_name
  count   = "1"
}

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
        timezone: Asia/Shanghai
        
        # https://cloudinit.readthedocs.io/en/latest/reference/modules.html#write-files
        write_files:
          # Set-CgroupConfig
          # https://github.com/containers/podman/blob/main/troubleshooting.md#26-running-containers-with-resource-limits-fails-with-a-permissions-error
          - path: /etc/systemd/system/user@1001.service.d/ansible-podman-rootless-provision.conf
            owner: root:root
            content: |
              # BEGIN ansible-podman-rootless-provision systemd_cgroup_delegate
              [Service]
              Delegate=cpu cpuset io memory pids
              # END ansible-podman-rootless-provision systemd_cgroup_delegate
          # Set-SysctlParams
          # https://github.com/containers/podman/blob/main/troubleshooting.md#5-rootless-containers-cannot-ping-hosts
          - path: /etc/sysctl.d/ansible-podman-rootless-provision.conf
            owner: root:root
            content: |
              net.ipv4.ping_group_range=0 2000000
              net.ipv4.ip_unprivileged_port_start=53

        # https://gist.github.com/wipash/81064e811c08191428002d7fe5da5ca7
        # https://cloudinit.readthedocs.io/en/latest/reference/examples.html#yaml-examples
        users:
          - name: vagrant
            gecos: vagrant
            groups: wheel
            plain_text_passwd: vagrant
            lock_passwd: false
            sudo: ALL=(ALL) NOPASSWD:ALL
            shell: /bin/bash
            ssh_import_id: None
            ssh_authorized_keys:
              - ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key
          - name: podmgr
            uid: 1001
            gecos: podmgr
            plain_text_passwd: podmgr
            lock_passwd: false
            shell: /bin/bash
            ssh_import_id: None
            ssh_authorized_keys:
              - ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key
        
        # https://cloudinit.readthedocs.io/en/latest/reference/modules.html#package-update-upgrade-install
        package_update: true
        package_upgrade: true
        package_reboot_if_required: true
        packages:
          - git
          - python3-pip
          - python3-jmespath
          - cockpit
          - cockpit-pcp
          - cockpit-podman
          - podman
        
        # https://cloudinit.readthedocs.io/en/latest/reference/examples.html#disk-setup
        disk_setup:
          /dev/sdb:
            table_type: gpt
            layout: True
            overwrite: False

        fs_setup:
          - label: Data
            filesystem: 'xfs'
            device: '/dev/sdb'
            partition: auto
            overwrite: false

        # https://cloudinit.readthedocs.io/en/latest/reference/examples.html#adjust-mount-points-mounted
        # https://zhuanlan.zhihu.com/p/250658106
        mounts:
          - [ /dev/disk/by-label/Data, /home/podmgr, auto, "nofail,exec", ]
        mount_default_fields: [ None, None, "auto", "nofail", "0", "2" ]

        # https://unix.stackexchange.com/questions/728955/why-is-the-root-filesystem-so-small-on-a-clean-fedora-37-install
        # https://cloudinit.readthedocs.io/en/latest/reference/modules.html#growpart
        growpart:
          mode: auto
          devices:
            - "/dev/sda3"
          ignore_growroot_disabled: false
        resize_rootfs: true
        
        # https://gist.github.com/corso75/582d03db6bb9870fbf6466e24d8e9be7
        runcmd:
          - chown podmgr:podmgr /home/podmgr
          # https://access.redhat.com/solutions/4661741
          - sudo -u podmgr /bin/bash -c "export XDG_RUNTIME_DIR=/run/user/$(id -u podmgr); /usr/bin/systemctl enable --now podman.socket --user"
          - firewall-offline-cmd --set-default-zone=trusted
          - firewall-offline-cmd --zone=trusted --add-service=cockpit
          - systemctl unmask firewalld
          - systemctl enable --now firewalld
          - systemctl enable --now cockpit.socket
        
        ansible:
          install_method: distro
          package_name: ansible-core
          run_user: vagrant
          galaxy:
            actions:
              - ["ansible-galaxy", "collection", "install", "community.general", "ansible.posix"]
          setup_controller:
            repositories:
              - path: /home/vagrant/SoloLab/
                source: https://github.com/fsdrw08/SoloLab.git
            run_ansible:
              - playbook_dir: /home/vagrant/SoloLab/AnsibleWorkShop/runner/project/
                playbook_name: Invoke-PodmanRootlessProvision.yml
                inventory: /home/vagrant/SoloLab/AnsibleWorkShop/runner/inventory/SoloLab.yml
                extra_vars: host_admin=localhost extravars_file=/home/vagrant/SoloLab/AnsibleWorkShop/runner/env/extravars
        EOT
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
              - 192.168.255.1${count.index + 0}/255.255.255.0
              - 192.168.255.1${count.index + 1}/255.255.255.0
            gateway4: 192.168.255.1
            nameservers:
              addresses: 192.168.255.1
        EOT
        # network:
        #   version: 1
        #   config:
        #     - type: physical
        #       name: eth0
        #       subnets:
        #         - type: static
        #           address: 192.168.255.1${count.index + 1}/24
        #           gateway: 192.168.255.1
        #           dns_nameservers:
        #             - 192.168.255.1
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
    vm_name       = local.count <= 1 ? "${local.vm_name}" : "${local.vm_name}${count.index + 1}"
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
  # path   = "C:\\ProgramData\\Microsoft\\Windows\\Virtual Hard Disks\\InfraSvc-Fedora38\\InfraSvc-Fedora38.vhdx"
  path = join("\\", [
    local.vhd_dir,
    var.vm_name,
    element(split("\\", var.source_disk), length(split("\\", var.source_disk)) - 1)
    ]
  )
  source = var.source_disk
}

data "terraform_remote_state" "data_disk" {
  backend = "local"
  config = {
    path = "${path.module}/${var.data_disk_ref}"
  }
}

module "hyperv_machine_instance" {
  source     = "../modules/hyperv_instance"
  depends_on = [null_resource.remote]
  count      = local.count

  vm_instance = {
    name                 = local.count <= 1 ? local.vm_name : "${local.vm_name}${count.index + 1}"
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
        path                = local.count <= 1 ? join("\\", ["${local.vhd_dir}", "${local.vm_name}", "${module.cloudinit_nocloud_iso[count.index].isoName}"]) : join("\\", ["${local.vhd_dir}", "${local.vm_name}${count.index + 1}", "${module.cloudinit_nocloud_iso[count.index].isoName}"])
      }
    ]

    hard_disk_drives = [
      {
        controller_type     = "Scsi"
        controller_number   = "0"
        controller_location = "0"
        path                = hyperv_vhd.boot_disk.path
      },
      {
        controller_type     = "Scsi"
        controller_number   = "0"
        controller_location = "2"
        path                = data.terraform_remote_state.data_disk.outputs.path
      }
    ]
  }
}
