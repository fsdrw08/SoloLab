resource "alicloud_resource_manager_resource_group" "devops" {
  resource_group_name = "devops"
  display_name        = "DevOps"
}

resource "alicloud_vpc" "devops" {
  vpc_name          = "DevOps"
  cidr_block        = "172.16.0.0/12"
  resource_group_id = alicloud_resource_manager_resource_group.devops.id
  description       = "This resource is managed by terraform"
  tags = {
    "Name" = "DevOps"
  }
}

// According to the vswitch cidr blocks to launch several vswitches
resource "alicloud_vswitch" "vswitches" {
  # count        = local.create_sub_resources ? length(var.vswitch_cidrs) : 0
  vpc_id       = alicloud_vpc.devops.id
  cidr_block   = var.vswitch_cidrs[count.index]
  zone_id      = element(var.availability_zones, count.index)
  vswitch_name = length(var.vswitch_cidrs) > 1 || var.use_num_suffix ? format("%s%03d", var.vswitch_name, count.index + 1) : var.vswitch_name
  description  = var.vswitch_description
  tags = merge(
    {
      Name = format(
        "%s%03d",
        var.vswitch_name,
        count.index + 1
      )
    },
    var.vswitch_tags,
  )
}
