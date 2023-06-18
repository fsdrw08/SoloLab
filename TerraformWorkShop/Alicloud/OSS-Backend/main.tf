# https://help.aliyun.com/document_detail/145541.html#section-ikv-9za-fsj
# https://github.com/terraform-alicloud-modules/terraform-alicloud-remote-backend/blob/master/main.tf
module "remote_state" {
  source                = "terraform-alicloud-modules/remote-backend/alicloud"
  version               = "1.2.0"
  create_backend_bucket = true
  backend_oss_bucket    = "terraform-remote-backend-root"

  create_ots_lock_instance = true
  # 注意，为了避免OTS实例名称的冲突，此处需要指定自己的OTS Instance名称
  # 如果指定的OTS Instance已经存在，那么需要设置 create_ots_lock_instance = false 
  backend_ots_lock_instance = "tf-ots-lock" # the default one "tf-oss-backend" shows already exist

  create_ots_lock_table = true
  # 注意，如果想要自定义OTS Table或者使用已经存在的Table，可以通过参数backend_ots_lock_table来指定
  # 如果指定的OTS Table已经存在，那么需要设置 create_ots_lock_table = false
  backend_ots_lock_table = "terraform_remote_backend_lock_table_root"

  region        = "ap-southeast-1" # means singapore
  state_name    = "root/terraform.tfstate"
  encrypt_state = false
}
