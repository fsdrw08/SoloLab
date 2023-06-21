data "terraform_remote_state" "vpc" {
  backend = "oss"
  config = {
    profile             = "default"
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

locals {
  eip_count = 2
}
resource "alicloud_eip_address" "devops" {
  count                = local.eip_count
  address_name         = "Devops_EIP-${count.index + 1}"
  bandwidth            = 5
  description          = "This resource is managed by terraform"
  internet_charge_type = "PayByTraffic"
  isp                  = "BGP"
  payment_type         = "PayAsYouGo"
  resource_group_id    = data.terraform_remote_state.vpc.outputs.resource_group_id
}


# https://github.com/alibaba/terraform-provider/blob/fbeb53e990dfde330c7c2e9fce5630ac56138d32/examples/vpc-snat/main.tf#L50
resource "alicloud_nat_gateway" "devops" {
  internet_charge_type = "PayByLcu"
  description          = "This resource is managed by terraform"
  nat_gateway_name     = "DevOps_NAT_Gateway"
  nat_type             = "Enhanced"
  network_type         = "internet"
  specification        = "Small"
  vpc_id               = data.terraform_remote_state.vpc.outputs.vpc_id
  vswitch_id           = data.terraform_remote_state.vpc.outputs.vswitch_id
}

resource "alicloud_eip_association" "devops" {
  count         = local.eip_count
  allocation_id = alicloud_eip_address.devops.*.id[count.index]
  instance_id   = alicloud_nat_gateway.devops.id
}

resource "alicloud_snat_entry" "default" {
  depends_on        = [alicloud_eip_association.devops]
  snat_table_id     = alicloud_nat_gateway.devops.snat_table_ids
  source_vswitch_id = data.terraform_remote_state.vpc.outputs.vswitch_id
  snat_ip           = alicloud_eip_address.devops[0].ip_address
}
