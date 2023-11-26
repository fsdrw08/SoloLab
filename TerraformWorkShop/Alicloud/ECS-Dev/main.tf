locals {
  count = 1
}

data "alicloud_resource_manager_resource_groups" "rg" {
  name_regex = var.resource_group_name_regex
}

data "alicloud_vpcs" "vpc" {
  name_regex        = var.vpc_name_regex
  resource_group_id = data.alicloud_resource_manager_resource_groups.rg.groups.0.id
}

data "alicloud_vswitches" "vsw" {
  name_regex        = var.vswitch_name_regex
  resource_group_id = data.alicloud_resource_manager_resource_groups.rg.groups.0.id
  vpc_id            = data.alicloud_vpcs.vpc.vpcs.0.id
}

data "alicloud_security_groups" "sg" {
  name_regex        = var.security_group_name_regex
  resource_group_id = data.alicloud_resource_manager_resource_groups.rg.groups.0.id
  vpc_id            = data.alicloud_vpcs.vpc.vpcs.0.id
}

data "alicloud_images" "img" {
  # name_regex  = var.ecs_image_name_regex
  image_id    = var.ecs_image_id
  most_recent = true
  # owners      = "others"
  # status = "Available"
}

data "alicloud_regions" "current_region_ds" {
  current = true
}

# core user ssh key pair
resource "tls_private_key" "core" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "alicloud_ecs_key_pair" "core" {
  key_pair_name     = "${var.ecs_server_name}_core"
  resource_group_id = data.alicloud_resource_manager_resource_groups.rg.groups.0.id
  public_key        = tls_private_key.core.public_key_openssh
}

# podmgr ssh key pair
resource "tls_private_key" "podmgr" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

data "ignition_config" "ignition" {
  count = local.count
  # disks       = [data.ignition_disk.data.rendered]
  # filesystems = [data.ignition_filesystem.data.rendered]
  systemd = [
    # data.ignition_systemd_unit.data.rendered,
    data.ignition_systemd_unit.rpm_ostree.rendered
  ]
  directories = [
    # data.ignition_directory.podmgr.rendered,
    data.ignition_directory.rootless_default_target_wants.rendered,
  ]
  users = [
    data.ignition_user.core.rendered,
    data.ignition_user.podmgr.rendered
  ]
  files = [
    # data.ignition_file.hostname[count.index].rendered,
    # data.ignition_file.disable_dhcp.rendered,
    # data.ignition_file.eth0[count.index].rendered,
    data.ignition_file.rpms.rendered,
    data.ignition_file.rootless_podman_socket_tcp.rendered,
    data.ignition_file.rootless_linger.rendered,
    data.ignition_file.enable_password_auth.rendered,
  ]
  links = [
    data.ignition_link.timezone.rendered,
    data.ignition_link.rootless_podman_socket_unix.rendered,
    # if dont want to expose podman tcp socket, just comment below line
    data.ignition_link.rootless_podman_socket_tcp.rendered,
  ]
}

# https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/instance
resource "alicloud_instance" "ecs" {
  count = local.count

  resource_group_id = data.alicloud_resource_manager_resource_groups.rg.groups.0.id
  availability_zone = data.alicloud_vswitches.vsw.vswitches.0.zone_id
  security_groups   = [data.alicloud_security_groups.sg.groups.0.id]
  vswitch_id        = data.alicloud_vswitches.vsw.vswitches.0.id

  # https://www.alibabacloud.com/help/zh/elastic-compute-service/latest/instance-family#t6
  instance_type = var.ecs_instance_type
  instance_name = local.count <= 1 ? var.ecs_instance_name : "${var.ecs_instance_name}${count.index + 1}"
  description   = "This resource is managed by terraform"

  status       = var.ecs_status # Running / Stopped
  stopped_mode = "StopCharging"

  image_id                = data.alicloud_images.img.images[0].id
  system_disk_category    = "cloud_efficiency"
  system_disk_name        = var.ecs_system_disk_name
  system_disk_description = "This resource is managed by terraform"

  host_name = var.ecs_server_name
  key_name  = alicloud_ecs_key_pair.core.key_pair_name

  user_data = data.ignition_config.ignition[count.index].rendered
}
