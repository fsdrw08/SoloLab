variable "prov_remote" {
  type = object({
    host     = string
    port     = number
    user     = string
    password = string
  })
}

variable "podman_kube" {
  type = object({
    helm = object({
      name   = string
      chart  = string
      values = string
    })
    manifest_dest_path = string
  })
}

variable "podman_quadlet" {
  type = object({
    files = list(object({
      template = string
      vars     = map(string)
      dir      = string
    }))
    service = object({
      name   = string
      status = string
    })
  })
}
