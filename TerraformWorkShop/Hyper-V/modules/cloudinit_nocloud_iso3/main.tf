data "archive_file" "cloudinit" {
  type        = "zip"
  output_path = "${path.root}/${var.iso_name}.zip"
  dynamic "source" {
    for_each = flatten([var.files])
    content {
      content  = source.value.content
      filename = source.value.filename
    }
  }
}

resource "hyperv_iso_image" "cloudinit" {
  volume_name               = "CIDATA"
  source_zip_file_path      = data.archive_file.cloudinit.output_path
  source_zip_file_path_hash = data.archive_file.cloudinit.output_sha
  iso_file_system_type      = "iso9660|joliet"
  destination_iso_file_path = var.destination_iso_file_path
}
