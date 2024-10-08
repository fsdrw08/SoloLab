variable "iso_name" {
  type        = string
  description = "file name for the cloudinit nocloud iso"
}

variable "files" {
  type = list(object({
    content  = string
    filename = string
  }))
  description = "files in the iso"
}

variable "destination_iso_file_path" {
  type        = string
  description = "iso file path in the hyper-v host"
}
