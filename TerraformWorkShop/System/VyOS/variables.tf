variable "vm_conn" {
  type = object({
    host     = string
    port     = number
    user     = string
    password = string
  })
}

variable "tftp" {
  type = object({
    address = string
    dir = object({
      path = string
      own_by = object({
        user  = string
        group = string
      })
    })
  })
}

variable "consul" {
  type = object({
    install = object({
      zip_file_source = string
      zip_file_path   = string
      bin_file_dir    = string
    })
    runas = object({
      user  = string
      group = string
    })
    storage = object({
      dir_target = string
      dir_link   = string
    })
    config = object({
      file_source   = string
      file_path_dir = string
      vars          = optional(map(string))
    })
    init_script = optional(object({
      file_source = string
      vars        = optional(map(string))
    }))
    service = object({
      status  = string
      enabled = bool
      systemd_unit_service = object({
        file_source = string
        file_path   = string
        vars        = optional(map(string))
      })
    })
  })
}

variable "consul_post_process" {
  type = map(object({
    script_path = string
    vars        = optional(map(string))
  }))
}

variable "stepca" {
  type = object({
    install = object({
      server = object({
        tar_file_source = string
        tar_file_path   = string
        bin_file_dir    = string
      })
      client = object({
        tar_file_source = string
        tar_file_path   = string
        bin_file_dir    = string
      })
    })
    runas = object({
      user  = string
      group = string
    })
    storage = object({
      dir_target = string
      dir_link   = string
    })
    init_script = optional(object({
      file_source = string
    }))
    config = object({
      file_source   = string
      vars          = optional(map(string))
      file_path_dir = string
    })
    service = object({
      status  = string
      enabled = bool
      systemd = object({
        file_source = string
        vars        = optional(map(string))
        file_path   = string
      })
    })
  })
}

variable "traefik" {
  type = object({
    install = object({
      tar_file_source = string
      tar_file_path   = string
      bin_file_dir    = string
    })
    runas = object({
      user  = string
      group = string
    })
    storage = object({
      dir_target = string
      dir_link   = string
    })
    config = object({
      static = object({
        file_source   = string
        vars          = optional(map(string))
        file_path_dir = string
      })
      dynamic = object({
        file_contents = list(object({
          file_source = string
          vars        = map(string)
        }))
        file_path_dir = string
      })
    })
    init_script = optional(object({
      file_source = string
      vars        = optional(map(string))
    }))
    service = object({
      traefik_restart = object({
        status  = string
        enabled = bool
        systemd_unit_service = object({
          file_source = string
          vars        = optional(map(string))
          file_path   = string
        })
        systemd_unit_path = object({
          file_source = string
          vars        = optional(map(string))
          file_path   = string
        })
      })
      traefik = object({
        status  = string
        enabled = bool
        systemd_unit_service = object({
          file_source = string
          vars        = optional(map(string))
          file_path   = string
        })
      })
    })
  })
}

variable "minio" {
  type = object({
    install = object({
      server = object({
        bin_file_source = string
        bin_file_dir    = string
      })
    })
    runas = object({
      user  = string
      group = string
    })
    storage = object({
      dir_target = string
    })
    config = object({
      file_source = string
      vars        = optional(map(string))
      file_path   = string
    })
    service = object({
      minio_restart = object({
        status  = string
        enabled = bool
        systemd_unit_service = object({
          file_source = string
          vars        = optional(map(string))
          file_path   = string
        })
        systemd_unit_path = object({
          file_source = string
          vars        = optional(map(string))
          file_path   = string
        })
      })
      minio = object({
        status  = string
        enabled = bool
        systemd_unit_service = object({
          file_source = string
          vars        = optional(map(string))
          file_path   = string
        })
      })
    })
  })
}

variable "minio_certs" {
  type = object({
    dir            = string
    CAs_dir_link   = string
    CAs_dir_target = string
  })
}
