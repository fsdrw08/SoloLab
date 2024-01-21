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
    service = object({
      name   = string
      status = string
    })
    quadlet = object({
      file_contents = list(object({
        file_source = string
        vars        = map(string)
      }))
      file_path_dir = string
    })
  })
}

variable "podman_kube_jenkins" {
  type = object({
    ext_vol_dir = optional(list(string))
    helm = object({
      chart  = string
      values = string
    })
    yaml_file_dir = string
  })
}

variable "podman_quadlet_jenkins" {
  type = object({
    service = object({
      name   = string
      status = string
    })
    quadlet = object({
      file_contents = list(object({
        file_source = string
        # https://stackoverflow.com/questions/63180277/terraform-map-with-string-and-map-elements-possible
        vars = map(list(string))
      }))
      file_path_dir = string
    })
  })
}
