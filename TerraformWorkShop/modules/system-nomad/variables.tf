variable "vm_conn" {
  type = object({
    host        = string
    port        = number
    user        = string
    password    = optional(string, null)
    private_key = optional(string, null)
  })
}

# variable "runas" {
#   type = object({
#     take_charge = optional(bool, false)
#     user        = string
#     uid         = number
#     group       = string
#     gid         = number
#   })
# }

variable "install" {
  type = list(object({
    zip_file_source = string
    zip_file_path   = string
    bin_file_name   = string
    bin_file_dir    = string
  }))
}
