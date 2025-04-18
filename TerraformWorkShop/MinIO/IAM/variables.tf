variable "prov_minio" {
  type = object({
    minio_server   = string
    minio_user     = string
    minio_password = string
    minio_ssl      = bool
  })
}

variable "policies" {
  type = list(object({
    name   = string
    policy = string
  }))
}
