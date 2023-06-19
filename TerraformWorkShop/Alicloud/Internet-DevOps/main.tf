data "terraform_remote_state" "vpc" {
  backend = "oss"
  config = {
    bucket              = "terraform-remote-backend-root"
    prefix              = ""
    key                 = "devops-test/vpc/terraform.tfstate"
    acl                 = "private"
    region              = "ap-southeast-1"
    encrypt             = "false"
    tablestore_endpoint = "https://tf-ots-lock.ap-southeast-1.ots.aliyuncs.com"
    tablestore_table    = "terraform_remote_backend_lock_table_root"
  }
}

resource "alicloud_eip_address" "devops" {
  address_name         = "Devops_EIP"
  bandwidth            = 1
  description          = "This resource is managed by terraform"
  internet_charge_type = "PayByTraffic"
  isp                  = "BGP"
  payment_type         = "PayAsYouGo"
  resource_group_id    = data.terraform_remote_state.vpc.outputs.resource_group_id
}

