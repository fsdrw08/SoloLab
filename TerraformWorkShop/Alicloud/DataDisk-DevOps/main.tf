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
    assume_role         = null
  }
}

resource "alicloud_ecs_disk" "gitlab_data" {
  resource_group_id = data.terraform_remote_state.vpc.outputs.resource_group_id
  category          = "cloud_efficiency"
  disk_name         = "DevOps_Disk-gitlab_data"
  description       = "This resource is managed by terraform"
  size              = "200"
  zone_id           = data.terraform_remote_state.vpc.outputs.vswitch_zone_id
}
