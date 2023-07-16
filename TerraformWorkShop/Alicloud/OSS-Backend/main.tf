# https://help.aliyun.com/document_detail/145541.html#section-ikv-9za-fsj
# https://github.com/terraform-alicloud-modules/terraform-alicloud-remote-backend/blob/master/main.tf

data "alicloud_regions" "regions" {
  current = true
}

locals {
  region              = var.region != "" ? var.region : data.alicloud_regions.regions.ids.0
  lock_table_endpoint = "https://${var.ots_instance_name}.${local.region}.ots.aliyuncs.com"
}

# OSS Bucket to hold state.
resource "alicloud_oss_bucket" "bucket" {
  acl    = "private"
  bucket = var.bucket_name

  tags = {
    Name      = "TF remote state"
    Terraform = "true"
  }
}

# OTS table store to lock state during applies
resource "alicloud_ots_instance" "ots_inst" {
  name        = var.ots_instance_name
  description = "Terraform remote backend state lock."
  accessed_by = "Any"
  tags = {
    Purpose = "Terraform state lock for state in ${var.bucket_name}"
  }
}

resource "alicloud_ots_table" "ots_tbl" {
  instance_name = alicloud_ots_instance.ots_inst.name
  max_version   = 1
  table_name    = var.ots_table_name
  time_to_live  = -1
  primary_key {
    name = "LockID"
    type = "String"
  }
}
