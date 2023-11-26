resource "alicloud_oss_bucket_object" "fcos" {
  bucket = var.oss_image_bucket
  key = join("/", [
    var.oss_image_dir,
    element(split("/", var.oss_image_source), length(split("/", var.oss_image_source)) - 1)
    ]
  )
  source = var.oss_image_source
}

resource "alicloud_image_import" "fcos" {
  image_name = element(split("/", var.oss_image_source), length(split("/", var.oss_image_source)) - 1)
  platform   = var.oss_image_distro
  disk_device_mapping {
    oss_bucket = var.oss_image_bucket
    oss_object = join("/", [
      var.oss_image_dir,
      element(split("/", var.oss_image_source), length(split("/", var.oss_image_source)) - 1)
      ]
    )
  }
}
