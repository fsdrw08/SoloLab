data "alicloud_zones" "vswitch" {
  available_resource_creation = "VSwitch"
}

# resource group
resource "alicloud_resource_manager_resource_group" "devops" {
  resource_group_name = "devops"
  display_name        = "DevOps"
}

# vpc related
resource "alicloud_vpc" "devops" {
  vpc_name          = "DevOps"
  cidr_block        = "172.16.0.0/12"
  resource_group_id = alicloud_resource_manager_resource_group.devops.id
  description       = "This resource is managed by terraform"
  tags = {
    "Name" = "DevOps"
  }
}

resource "alicloud_vswitch" "devops" {
  vpc_id       = alicloud_vpc.devops.id
  cidr_block   = "172.16.1.0/24"
  zone_id      = data.alicloud_zones.vswitch.zones[0].id
  vswitch_name = "DevOps"
  description  = "This resource is managed by terraform"
  tags = {
    "Name" = "DevOps"
  }
}

# security group related
resource "alicloud_security_group" "devops" {
  name                = "DevOps"
  resource_group_id   = alicloud_resource_manager_resource_group.devops.id
  security_group_type = "normal"
  vpc_id              = alicloud_vpc.devops.id
}

resource "alicloud_security_group_rule" "allow_all_tcp" {
  type              = "ingress"
  ip_protocol       = "tcp"
  port_range        = "1/65535"
  nic_type          = "intranet"
  policy            = "accept"
  priority          = 10
  security_group_id = alicloud_security_group.devops.id
  cidr_ip           = "0.0.0.0/0"
}

