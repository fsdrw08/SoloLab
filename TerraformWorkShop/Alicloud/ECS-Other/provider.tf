terraform {
  required_providers {
    system = {
      source  = "neuspaces/system"
      version = ">=0.4.0"
    }
  }
  backend "oss" {
    profile             = "cn_hk"
    region              = "cn-hongkong"
    bucket              = "terraform-remote-backend-9c53"
    prefix              = ""
    key                 = "devops/ecs-other/terraform.tfstate"
    acl                 = "private"
    encrypt             = "false"
    tablestore_endpoint = "https://tf-state-lock.cn-hongkong.ots.aliyuncs.com"
    tablestore_table    = "terraform_remote_backend_lock_table"
  }
}

provider "system" {
  ssh {
    host     = var.server.host
    port     = var.server.port
    user     = var.server.user
    password = var.server.password
  }
}
