# https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/nas_file_system#file_system_type
variable "resource_group_name_regex" {
  type    = string
  default = "^DevOps-Root"
}

variable "vpc_name_regex" {
  type    = string
  default = "^DevOps-VPC"
}

variable "vswitch_name_regex" {
  type    = string
  default = "^DevOps-Sub_1_VSw"
}

variable "nas_fs_desc" {
  type        = string
  description = <<-EOT
  The description must be 2 to 128 characters in length
  The description must start with a letter and cannot start with http:// or https://.
  The description can contain letters, digits, colons (:), underscores (_), and hyphens (-).
  EOT
}

variable "nas_fs_type" {
  description = "The type of the file system. Valid values: standard # 通用型NAS, extreme, cpfs."
  type        = string
  default     = "standard"
}

variable "nas_fs_storage_type" {
  description = <<-EOT
The storage type of the file System.
Valid values:
Performance (Available when the file_system_type is standard) # 性能型
Capacity (Available when the file_system_type is standard)
standard (Available in v1.140.0+ and when the file_system_type is extreme)
advance (Available in v1.140.0+ and when the file_system_type is extreme)
advance_100 (Available in v1.153.0+ and when the file_system_type is cpfs)
advance_200 (Available in v1.153.0+ and when the file_system_type is cpfs)
EOT
  type        = string
  # https://help.aliyun.com/zh/nas/product-overview/general-purpose-nas-file-systems?spm=a2c4g.11186623.0.0.15336a54Dk3LvU
  default = "Performance"
}

variable "nas_fs_protocol_type" {
  description = "The protocol type of the file system. Valid values: NFS, SMB (Available when the file_system_type is standard), cpfs (Available when the file_system_type is cpfs)."
  type        = string
  default     = "NFS"
}

variable "nas_ag_name" {
  description = "A Name of one Access Group."
  type        = string
  default     = "DevOps-NAS_AG"
}

variable "nas_ar_rw_access_type" {
  description = "NAS access rule Read-write permission type"
  type        = string
  default     = "RDWR"
}
