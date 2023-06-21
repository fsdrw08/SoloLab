data "terraform_remote_state" "vpc" {
  backend = "oss"
  config = {
    region              = "ap-southeast-1"
    bucket              = "terraform-remote-backend-root"
    prefix              = ""
    key                 = "devops-test/vpc/terraform.tfstate"
    acl                 = "private"
    encrypt             = "false"
    tablestore_endpoint = "https://tf-ots-lock.ap-southeast-1.ots.aliyuncs.com"
    tablestore_table    = "terraform_remote_backend_lock_table_root"
    assume_role         = null
  }
}

data "terraform_remote_state" "internet" {
  backend = "oss"
  config = {
    region              = "ap-southeast-1"
    bucket              = "terraform-remote-backend-root"
    prefix              = ""
    key                 = "devops-test/internet/terraform.tfstate"
    acl                 = "private"
    encrypt             = "false"
    tablestore_endpoint = "https://tf-ots-lock.ap-southeast-1.ots.aliyuncs.com"
    tablestore_table    = "terraform_remote_backend_lock_table_root"
    assume_role         = null
  }
}

data "terraform_remote_state" "data_disk" {
  backend = "oss"
  config = {
    bucket              = "terraform-remote-backend-root"
    prefix              = ""
    key                 = "devops-test/compute/data_disk/terraform.tfstate"
    acl                 = "private"
    region              = "ap-southeast-1"
    encrypt             = "false"
    tablestore_endpoint = "https://tf-ots-lock.ap-southeast-1.ots.aliyuncs.com"
    tablestore_table    = "terraform_remote_backend_lock_table_root"
    assume_role         = null
  }
}

data "alicloud_images" "centos_stream" {
  name_regex  = "^centos_stream_9_x64"
  most_recent = true
  owners      = "system"
  status      = "Available"
}


# root ssh key pair
# https://stackoverflow.com/questions/49743220/how-do-i-create-an-ssh-key-in-terraform
resource "tls_private_key" "gitlab_root" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "alicloud_ecs_key_pair" "gitlab_root" {
  key_pair_name     = "gitlab_root"
  resource_group_id = data.terraform_remote_state.vpc.outputs.resource_group_id
  public_key        = tls_private_key.gitlab_root.public_key_openssh
}

# https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/instance
resource "alicloud_instance" "gitlab" {
  resource_group_id = data.terraform_remote_state.vpc.outputs.resource_group_id

  availability_zone = data.terraform_remote_state.vpc.outputs.vswitch_zone_id
  security_groups   = [data.terraform_remote_state.vpc.outputs.security_group_id]
  vswitch_id        = data.terraform_remote_state.vpc.outputs.vswitch_id

  # https://www.alibabacloud.com/help/zh/elastic-compute-service/latest/instance-family#t6
  instance_type = "ecs.t6-c1m2.large"
  instance_name = "DevOps_Compute-gitlab"
  description   = "This resource is managed by terraform"
  key_name      = alicloud_ecs_key_pair.gitlab_root.key_pair_name
  status        = "Running" # Running / Stopped

  image_id                = data.alicloud_images.centos_stream.images[0].id
  system_disk_category    = "cloud_efficiency"
  system_disk_name        = "DevOps_Disk-gitlab_boot"
  system_disk_description = "This resource is managed by terraform"

}

resource "alicloud_ecs_disk_attachment" "gitlab_data_attach" {
  disk_id     = data.terraform_remote_state.data_disk.outputs.gitlab_data_disk_id
  instance_id = alicloud_instance.gitlab.id
}

# internet NIC
# https://www.alibabacloud.com/help/zh/nat-gateway/latest/configure-ecs-instances-that-configured-with-dnat-ip-mapping-to-use-the-same-nat-ip-address-to-access-the-internet
resource "alicloud_ecs_network_interface" "gitlab_internet_nic" {
  description            = "This resource is managed by terraform"
  network_interface_name = "DevOps_NIC-gitlab_internet"
  vswitch_id             = data.terraform_remote_state.vpc.outputs.vswitch_id
  resource_group_id      = data.terraform_remote_state.vpc.outputs.resource_group_id
  security_group_ids     = [data.terraform_remote_state.vpc.outputs.security_group_id]
}

// nic attachment
resource "alicloud_ecs_network_interface_attachment" "gitlab_nic_attach" {
  instance_id          = alicloud_instance.gitlab.id
  network_interface_id = alicloud_ecs_network_interface.gitlab_internet_nic.id
}

data "alicloud_ecs_network_interfaces" "gitlab_internet_nic" {
  depends_on        = [alicloud_ecs_disk_attachment.gitlab_data_attach]
  ids               = [alicloud_ecs_network_interface.gitlab_internet_nic.id]
  resource_group_id = data.terraform_remote_state.vpc.outputs.resource_group_id
}

resource "alicloud_forward_entry" "ssh" {
  forward_entry_name = "DevOps_DNAT-ssh"
  forward_table_id   = data.terraform_remote_state.internet.outputs.nat_gateway_forward_table_ids
  external_ip        = data.terraform_remote_state.internet.outputs.eip_addresses[1]
  external_port      = "8022"
  ip_protocol        = "tcp"
  # internal_ip        = alicloud_instance.gitlab.private_ip
  internal_ip   = data.alicloud_ecs_network_interfaces.gitlab_internet_nic.interfaces[0].private_ip
  internal_port = "22"
}
