# https://developer.hashicorp.com/terraform/language/settings/backends/oss
terraform {
  required_providers {
    alicloud = {
      source  = "aliyun/alicloud"
      version = ">=1.206.0"
    }
  }
}

terraform {
  backend "oss" {
    profile             = "cn_hk"
    bucket              = "terraform-remote-backend-9c53"
    prefix              = ""
    key                 = "root/terraform.tfstate"
    acl                 = "private"
    region              = "cn-hongkong"
    encrypt             = "false"
    tablestore_endpoint = "https://tf-state-lock.cn-hongkong.ots.aliyuncs.com"
    tablestore_table    = "terraform_remote_backend_lock_table"
  }
}


provider "alicloud" {
  profile = var.aliyun_profile
}
