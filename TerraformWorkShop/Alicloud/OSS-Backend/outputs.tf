output "oss_config" {
  value = <<-EOT
  add below content in provider.tf
    terraform {
      backend "oss" {
        profile             = "${var.aliyun_profile}"
        bucket              = "${var.bucket_name}"
        prefix              = "${var.state_path}"
        key                 = "${var.state_name}"
        acl                 = "${var.state_acl}"
        region              = "${local.region}"
        encrypt             = "${var.encrypt_state}"
        tablestore_endpoint = "${local.lock_table_endpoint}"
        tablestore_table    = "${alicloud_ots_table.ots_tbl.table_name}"
      }
    }
  EOT
}
