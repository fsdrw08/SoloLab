variable "vm_conn" {
  type = object({
    host     = string
    port     = number
    user     = string
    password = string
  })
}

variable "podman_kube_traefik" {
  type = object({
    ext_vol_dir = optional(string)
    helm = object({
      chart  = string
      values = string
    })
    yaml_file_dir = string
  })
}

variable "podman_quadlet_traefik" {
  type = object({
    service_status = string
    quadlet = object({
      file_contents = list(object({
        file_source = string
        vars        = map(string)
      }))
      file_path_dir = string
    })
  })
}
