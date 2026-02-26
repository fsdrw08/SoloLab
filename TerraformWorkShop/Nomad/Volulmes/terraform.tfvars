prov_nomad = {
  address     = "https://nomad.day1.sololab"
  skip_verify = true
}

dynamic_host_volumes = [
  {
    name = "redis"
    constraint = [
      {
        attribute = "$${attr.unique.hostname}"
        operator  = "=="
        value     = "day2"
      }
    ]
    capability = {
      access_mode = "single-node-writer"
    }
    plugin_id = "mkdir"
    parameters = {
      uid = 999
      gid = 1000
    }
  },
  {
    name = "redis-insight"
    constraint = [
      {
        attribute = "$${attr.unique.hostname}"
        operator  = "=="
        value     = "day2"
      }
    ]
    capability = {
      access_mode = "single-node-writer"
    }
    plugin_id = "mkdir"
    parameters = {
      uid = 1000
      gid = 1000
    }
  },
  {
    name = "nexus-db"
    constraint = [
      {
        attribute = "$${attr.unique.hostname}"
        operator  = "=="
        value     = "day2"
      }
    ]
    capability = {
      access_mode = "single-node-writer"
    }
    plugin_id = "mkdir"
    parameters = {
      uid = 26
      gid = 26
    }
  },
  # {
  #   name = "meilisearch"
  #   constraint = [
  #     {
  #       attribute = "$${attr.unique.hostname}"
  #       operator  = "=="
  #       value     = "day2"
  #     }
  #   ]
  #   capability = {
  #     access_mode = "single-node-writer"
  #   }
  #   plugin_id = "mkdir"
  #   parameters = {
  #     uid = 0
  #     gid = 0
  #   }
  # }
  {
    name = "gitblit"
    constraint = [
      {
        attribute = "$${attr.unique.hostname}"
        operator  = "=="
        value     = "day3"
      }
    ]
    capability = {
      access_mode = "single-node-writer"
    }
    plugin_id = "mkdir"
    parameters = {
      uid = 8117
      gid = 8117
    }
  },
  {
    name = "nexus"
    constraint = [
      {
        attribute = "$${attr.unique.hostname}"
        operator  = "=="
        value     = "day3"
      }
    ]
    capability = {
      access_mode = "single-node-writer"
    }
    plugin_id = "mkdir"
    parameters = {
      uid = 200
      gid = 200
    }
  },
]

csi_volumes = [
  # {
  #   name      = "nomad-gitblit-config"
  #   plugin_id = "nfs"
  #   volume_id = "gitblit-config"
  #   capabilities = [
  #     {
  #       access_mode     = "multi-node-multi-writer"
  #       attachment_mode = "file-system"
  #     },
  #     {
  #       access_mode     = "single-node-writer"
  #       attachment_mode = "file-system"
  #     }
  #   ]
  #   parameters = {
  #     server           = "192.168.255.10"
  #     share            = "/"
  #     mountPermissions = "777"
  #   }
  #   mount_options = {
  #     fs_type = "nfs"
  #   }
  # },
  # {
  #   name      = "nomad-gitblit-data"
  #   plugin_id = "nfs"
  #   volume_id = "gitblit-data"
  #   capabilities = [
  #     {
  #       access_mode     = "multi-node-multi-writer"
  #       attachment_mode = "file-system"
  #     },
  #     {
  #       access_mode     = "single-node-writer"
  #       attachment_mode = "file-system"
  #     }
  #   ]
  #   parameters = {
  #     server           = "192.168.255.10"
  #     share            = "/"
  #     mountPermissions = "777"
  #   }
  #   mount_options = {
  #     fs_type = "nfs"
  #   }
  # }
]

