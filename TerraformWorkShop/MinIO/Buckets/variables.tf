variable "prov_minio" {
  type = object({
    minio_server   = string
    minio_user     = string
    minio_password = string
    minio_ssl      = bool
  })
}

variable "buckets" {
  type = list(object({
    name   = string
    acl    = optional(string, null)
    policy = optional(string, null)
  }))
}
