data "alicloud_resource_manager_resource_groups" "rg" {
  name_regex = var.resource_group_name_regex
  status     = "OK"
}

# vpc
# https://mxtoolbox.com/SubnetCalculator.aspx
resource "alicloud_vpc" "vpc" {
  vpc_name          = var.vpc_name
  cidr_block        = var.vpc_cidr
  resource_group_id = data.alicloud_resource_manager_resource_groups.rg.groups.0.id
  description       = "This resource is managed by terraform"
  tags = {
    "Name" = var.vpc_name
  }
}


## ipv4 gateway
# https://help.aliyun.com/document_detail/376445.html
resource "alicloud_vpc_ipv4_gateway" "ipv4gw" {
  enabled                  = true
  vpc_id                   = alicloud_vpc.vpc.id
  resource_group_id        = data.alicloud_resource_manager_resource_groups.rg.groups.0.id
  ipv4_gateway_name        = var.ipv4_gateway_name
  ipv4_gateway_description = "This_resource_is_managed_by_terraform"
}

# create ipv4 gateway route table 创建网关路由表
# https://help.aliyun.com/document_detail/376499.html#section-pbr-i91-zye
resource "alicloud_route_table" "ipv4gw_vtb" {
  vpc_id           = alicloud_vpc.vpc.id
  route_table_name = var.ipv4_gateway_route_table_name
  description      = "This resource is managed by terraform"
  associate_type   = "Gateway"
}

# bind ipv4 gateway and ipv4 gateway route table together
# https://help.aliyun.com/document_detail/376499.html#section-8vm-dsm-lb1
resource "alicloud_vpc_gateway_route_table_attachment" "ipv4gw_vtb_attm" {
  ipv4_gateway_id = alicloud_vpc_ipv4_gateway.ipv4gw.id
  route_table_id  = alicloud_route_table.ipv4gw_vtb.id
}

# add vpc route entry to route traffic to ipv4 gateway 为VPC路由表添加指向IPv4网关的路由条目
# https://help.aliyun.com/document_detail/376499.html#section-l0k-okc-3q2
resource "alicloud_route_entry" "vpc_to_ipv4gw" {
  route_table_id        = alicloud_vpc.vpc.route_table_id
  nexthop_id            = alicloud_vpc_ipv4_gateway.ipv4gw.id
  destination_cidrblock = "0.0.0.0/0"
  nexthop_type          = "Ipv4Gateway"
}

## private zone
# Using this data source can open Private Zone service automatically.
# https://github.com/openshift/installer/blob/de6e40773cee904bfea1d2bafae4149d58277d83/data/data/alibabacloud/cluster/dns/privatezone.tf#L5
data "alicloud_pvtz_service" "pvtz_enable" {
  enable = "On"
}

resource "alicloud_pvtz_zone" "pvtz" {
  resource_group_id = data.alicloud_resource_manager_resource_groups.rg.groups.0.id
  zone_name         = "devops.p2w3"
  sync_status       = "ON"
  user_info {
    user_id    = var.private_zone_user_id
    region_ids = var.private_zone_region_ids
  }
}

resource "alicloud_pvtz_zone_attachment" "pvtz_attm" {
  zone_id = alicloud_pvtz_zone.pvtz.id
  vpc_ids = [alicloud_vpc.vpc.id]
}
