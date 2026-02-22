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
    name = "test-db"
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
  {
    name = "gitea-db"
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
  {
    name = "meilisearch"
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
      uid = 0
      gid = 0
    }
  }
]

csi_volumes = [
  {
    name      = "nomad-gitea-config"
    plugin_id = "nfs"
    volume_id = "gitea-config"
    capabilities = [
      {
        access_mode     = "multi-node-multi-writer"
        attachment_mode = "file-system"
      },
      {
        access_mode     = "single-node-writer"
        attachment_mode = "file-system"
      }
    ]
    parameters = {
      server           = "192.168.255.10"
      share            = "/"
      mountPermissions = "777"
    }
    mount_options = {
      fs_type = "nfs"
    }
  },
  {
    name      = "nomad-gitea-data"
    plugin_id = "nfs"
    volume_id = "gitea-data"
    capabilities = [
      {
        access_mode     = "multi-node-multi-writer"
        attachment_mode = "file-system"
      },
      {
        access_mode     = "single-node-writer"
        attachment_mode = "file-system"
      }
    ]
    parameters = {
      server           = "192.168.255.10"
      share            = "/"
      mountPermissions = "777"
    }
    mount_options = {
      fs_type = "nfs"
    }
  }
]

