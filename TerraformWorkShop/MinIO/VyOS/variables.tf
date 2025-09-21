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
    bucket         = string
    acl            = optional(string, null)
    bucket_prefix  = optional(string, null)
    force_destroy  = optional(bool, null)
    object_locking = optional(bool, null)
    quota          = optional(number, null)
  }))
  default = []
}

variable "users" {
  type = list(object({
    name       = string
    policies   = list(string)
    access_key = optional(string, null)
    secret_key = optional(string, null)
  }))
  default = []
}

variable "policies" {
  type = list(object({
    name   = string
    policy = string
  }))
  default = []
}
