variable "prov_sftpgo" {
  type = object({
    host     = string
    username = string
    password = string
    edition  = optional(number, 0)
  })
}

variable "virtual_folders" {
  type = list(object({
    name = string
    filesystem = object({
      # 0 = local filesystem, 
      # 1 = S3 Compatible, 2 = Google Cloud, 3 = Azure Blob,
      # 4 = Local encrypted, 5 = SFTP, 6 = HTTP
      provider = number
    })
    description = optional(string, null)
    mapped_path = optional(string, null)
  }))
}

variable "groups" {
  type = list(object({
    name = string
    user_settings = object({
      filesystem = object({
        # 0 = local filesystem, 
        # 1 = S3 Compatible, 2 = Google Cloud, 3 = Azure Blob,
        # 4 = Local encrypted, 5 = SFTP, 6 = HTTP
        provider = number
      })
      download_bandwidth     = optional(number, null)
      download_data_transfer = optional(number, null)
      expires_in             = optional(number, null)
      home_dir               = optional(string, null)
      max_sessions           = optional(number, null)
      permissions            = optional(map(string), null)
      quota_files            = optional(number, null)
      quota_size             = optional(number, null)
      total_data_transfer    = optional(number, null)
      upload_bandwidth       = optional(number, null)
      upload_data_transfer   = optional(number, null)
    })
    virtual_folders = list(object({
      name             = string
      quota_files      = optional(number, null)
      quota_size       = optional(number, null)
      virtual_path     = string
      description      = optional(string, null)
      mapped_path      = optional(string, null)
      used_quota_files = optional(number, null)
      used_quota_size  = optional(number, null)
    }))
  }))
}
