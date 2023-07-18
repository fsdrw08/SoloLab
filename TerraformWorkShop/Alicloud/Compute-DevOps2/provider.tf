terraform {
  required_providers {
    alicloud = {
      source  = "aliyun/alicloud"
      version = ">=1.206.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">=4.0.4"
    }
    local = {
      source  = "hashicorp/local"
      version = ">=2.4.0"
    }
  }

  backend "oss" {
    profile             = "cn_hk"
    region              = "cn-hongkong"
    bucket              = "terraform-remote-backend-9c53"
    prefix              = ""
    key                 = "devops/ecs-hk-agent/terraform.tfstate"
    acl                 = "private"
    encrypt             = "false"
    tablestore_endpoint = "https://tf-state-lock.cn-hongkong.ots.aliyuncs.com"
    tablestore_table    = "terraform_remote_backend_lock_table"
  }
}

provider "alicloud" {
  profile = "cn_hk"
}
