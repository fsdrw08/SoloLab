# https://developer.hashicorp.com/terraform/language/settings/backends/oss
terraform {
  backend "oss" {
    bucket              = "terraform-remote-backend-root"
    prefix              = ""
    key                 = "root/terraform.tfstate"
    acl                 = "private"
    region              = "ap-southeast-1"
    encrypt             = "false"
    tablestore_endpoint = "https://tf-ots-lock.ap-southeast-1.ots.aliyuncs.com"
    tablestore_table    = "terraform_remote_backend_lock_table_root"
  }
}
