variable "vm_conn" {
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
      set = optional(list(object({
        name  = string
        value = string
      })))
    })
    yaml_file_path = string
  })
}

variable "podman_quadlet" {
  type = object({
    service = object({
      name   = string
      status = string
    })
    quadlet = object({
      file_contents = list(object({
        file_source = string
        # https://stackoverflow.com/questions/63180277/terraform-map-with-string-and-map-elements-possible
        vars = map(string)
      }))
      file_path_dir = string
    })
  })
}

variable "container_restart" {
  type = object({
    systemd_path_unit = object({
      content = object({
        templatefile = string
        vars         = map(string)
      })
      path = string
    })
    systemd_service_unit = object({
      content = object({
        templatefile = string
        vars         = map(string)
      })
      path = string
    })
  })
}
