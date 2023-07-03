data "alicloud_resource_manager_resource_groups" "rg" {
  name_regex = "^${var.resource_group_name}"
}

data "alicloud_vpcs" "vpc" {
  name_regex        = "^${var.vpc_name}"
  resource_group_id = data.alicloud_resource_manager_resource_groups.rg.groups.0.id
}

data "alicloud_vswitches" "vsw" {
  name_regex        = "^${var.vswitch_name}"
  resource_group_id = data.alicloud_resource_manager_resource_groups.rg.groups.0.id
  vpc_id            = data.alicloud_vpcs.vpc.vpcs.0.id
}

data "alicloud_security_groups" "sg" {
  name_regex        = "^${var.security_group_name}"
  resource_group_id = data.alicloud_resource_manager_resource_groups.rg.groups.0.id
  vpc_id            = data.alicloud_vpcs.vpc.vpcs.0.id
}

data "alicloud_ecs_disks" "dd" {
  name_regex        = "^${var.data_disk_name}"
  resource_group_id = data.alicloud_resource_manager_resource_groups.rg.groups.0.id
}

data "alicloud_nat_gateways" "ngw" {
  name_regex        = "^${var.nat_gateway_name}"
  resource_group_id = data.alicloud_resource_manager_resource_groups.rg.groups.0.id
  vpc_id            = data.alicloud_vpcs.vpc.vpcs.0.id
}

data "alicloud_eip_addresses" "eip" {
  name_regex        = "^${var.eip_address_name}"
  resource_group_id = data.alicloud_resource_manager_resource_groups.rg.groups.0.id
}

data "alicloud_images" "img" {
  name_regex  = "^${var.ecs_image_name}"
  most_recent = true
  owners      = "system"
  status      = "Available"
}

data "alicloud_instances" "ecs" {
  name_regex        = "DevOps_Compute-${var.ecs_server_name}"
  resource_group_id = data.alicloud_resource_manager_resource_groups.rg.groups.0.id
  vpc_id            = data.alicloud_vpcs.vpc.vpcs.0.id
  vswitch_id        = data.alicloud_vswitches.vsw.vswitches.0.id
}

# root ssh key pair
resource "tls_private_key" "root" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "alicloud_ecs_key_pair" "root" {
  key_pair_name     = "${var.ecs_server_name}_root"
  resource_group_id = data.alicloud_resource_manager_resource_groups.rg.groups.0.id
  public_key        = tls_private_key.root.public_key_openssh
}

# admin ssh key pair
resource "tls_private_key" "admin" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_sensitive_file" "admin" {
  filename = "${path.module}/gitlab-admin.key"
  content  = tls_private_key.admin.private_key_openssh
}

# podmgr ssh key pair
resource "tls_private_key" "podmgr" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/instance
resource "alicloud_instance" "ecs" {
  resource_group_id = data.alicloud_resource_manager_resource_groups.rg.groups.0.id

  availability_zone = data.alicloud_vswitches.vsw.vswitches.0.zone_id
  security_groups   = [data.alicloud_security_groups.sg.groups.0.id]
  vswitch_id        = data.alicloud_vswitches.vsw.vswitches.0.id

  # https://www.alibabacloud.com/help/zh/elastic-compute-service/latest/instance-family#t6
  instance_type = var.ecs_instance_type
  instance_name = "DevOps_Compute-${var.ecs_server_name}"
  description   = "This resource is managed by terraform"

  status       = "Running" # Running / Stopped
  stopped_mode = "StopCharging"

  image_id                = data.alicloud_images.img.images[0].id
  system_disk_category    = "cloud_efficiency"
  system_disk_name        = "DevOps_Disk-${var.ecs_server_name}_boot"
  system_disk_description = "This resource is managed by terraform"

  host_name = var.ecs_server_name
  key_name  = alicloud_ecs_key_pair.root.key_pair_name

  user_data = <<-EOT
  #cloud-config
  timezone: Asia/Shanghai

  # https://cloudinit.readthedocs.io/en/latest/reference/modules.html#package-update-upgrade-install
  package_update: true
  package_upgrade: true
  package_reboot_if_required: false
  packages:
    - podman
    - cockpit
    - cockpit-pcp
    - cockpit-podman

  # https://gist.github.com/wipash/81064e811c08191428002d7fe5da5ca7
  # https://cloudinit.readthedocs.io/en/latest/reference/examples.html#yaml-examples
  users:
    - name: admin
      gecos: admin
      groups: wheel
      lock_passwd: true
      sudo: ALL=(ALL) NOPASSWD:ALL
      shell: /bin/bash
      ssh_import_id: None
      ssh_authorized_keys:
        - ${tls_private_key.admin.public_key_openssh}
    - name: podmgr
      gecos: podmgr
      lock_passwd: true
      sudo: False
      shell: /bin/bash
      ssh_import_id: None
      ssh_authorized_keys:
        - ${tls_private_key.podmgr.public_key_openssh}

  # https://cloudinit.readthedocs.io/en/latest/reference/examples.html#disk-setup
  disk_setup:
    /dev/vdb:
      table_type: gpt
      layout: True
      overwrite: False

  fs_setup:
    - label: Data
      filesystem: 'xfs'
      device: '/dev/vdb'
      partition: auto

  # https://cloudinit.readthedocs.io/en/latest/reference/examples.html#adjust-mount-points-mounted
  # https://zhuanlan.zhihu.com/p/250658106
  mounts:
    - [ /dev/vdb1, /home/podmgr, auto, "nofail,exec", ]
  mount_default_fields: [ None, None, "auto", "defaults,nofail,user", "0", "2" ]
  EOT
}

resource "alicloud_ecs_disk_attachment" "ecs_data_attach" {
  disk_id     = data.alicloud_ecs_disks.dd.disks.0.id
  instance_id = alicloud_instance.ecs.id
}

# internet NIC
# https://www.alibabacloud.com/help/zh/nat-gateway/latest/configure-ecs-instances-that-configured-with-dnat-ip-mapping-to-use-the-same-nat-ip-address-to-access-the-internet
# !! DO NOT assign 2 NICs in same subnet to the same server
# ref: 
# https://access.redhat.com/solutions/30564
# https://repost.aws/knowledge-center/ec2-ubuntu-secondary-network-interface

# resource "alicloud_ecs_network_interface" "internet_nic" {
#   description            = "This resource is managed by terraform"
#   network_interface_name = "DevOps_NIC-${var.ecs_server_name}_internet"
#   vswitch_id             = data.terraform_remote_state.vpc.outputs.vswitch_id
#   resource_group_id      = data.terraform_remote_state.vpc.outputs.resource_group_id
#   security_group_ids     = [data.terraform_remote_state.vpc.outputs.security_group_id]
# }

# nic attachment
# resource "alicloud_ecs_network_interface_attachment" "internet_nic_attach" {
#   instance_id          = alicloud_instance.ecs.id
#   network_interface_id = alicloud_ecs_network_interface.internet_nic.id
# }

# data "alicloud_ecs_network_interfaces" "internet_nic" {
#   ids               = [alicloud_ecs_network_interface.internet_nic.id]
#   resource_group_id = data.terraform_remote_state.vpc.outputs.resource_group_id
# }

resource "alicloud_forward_entry" "ssh" {
  forward_entry_name = "DevOps_DNAT-${var.ecs_server_name}_ssh"
  forward_table_id   = data.alicloud_nat_gateways.ngw.gateways[0].forward_table_ids[0]
  external_ip        = data.alicloud_eip_addresses.eip.addresses[var.eip_index].ip_address
  external_port      = "8022"
  ip_protocol        = "tcp"
  internal_ip        = alicloud_instance.ecs.private_ip
  internal_port      = "22"
  port_break         = true
}

# resource "alicloud_forward_entry" "http" {
#   forward_entry_name = "DevOps_DNAT-${var.ecs_server_name}_https"
#   forward_table_id   = data.alicloud_nat_gateways.ngw.gateways[0].forward_table_ids[0]
#   external_ip        = data.alicloud_eip_addresses.eip.addresses[var.eip_index].ip_address
#   external_port      = "80"
#   ip_protocol        = "tcp"
#   internal_ip        = alicloud_instance.ecs.private_ip
#   internal_port      = "80"
#   port_break         = true
# }

# resource "alicloud_forward_entry" "https" {
#   forward_entry_name = "DevOps_DNAT-${var.ecs_server_name}_https"
#   forward_table_id   = data.alicloud_nat_gateways.ngw.gateways[0].forward_table_ids[0]
#   external_ip        = data.alicloud_eip_addresses.eip.addresses[var.eip_index].ip_address
#   external_port      = "443"
#   ip_protocol        = "tcp"
#   internal_ip        = alicloud_instance.ecs.private_ip
#   internal_port      = "443"
#   port_break         = true
# }
