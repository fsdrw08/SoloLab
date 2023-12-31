variable "vm_conn" {
  type = object({
    host     = string
    port     = number
    user     = string
    password = string
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
      systemd = object({
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
      tar_file_source = string
      tar_file_path   = string
      bin_file_dir    = string
    })
    install_cli = object({
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
      file_source   = string
      vars          = optional(map(string))
      file_path_dir = string
    })
    init_script = optional(object({
      file_source = string
      vars        = optional(map(string))
    }))
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

variable "minio" {
  type = object({
    bin_file_source     = string
    systemd_file_source = string
    config_file_source  = string
  })
}
