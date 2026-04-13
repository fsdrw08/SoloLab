prov_nomad = {
  address     = "https://nomad.day1.sololab"
  skip_verify = true
}

dynamic_host_volumes = [
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
]

csi_volumes = [
  {
    name      = "nexus-cacerts"
    plugin_id = "nfs"
    volume_id = "nexus-cacerts"
    capabilities = [
      {
        access_mode     = "single-node-writer"
        attachment_mode = "file-system"
      }
    ]
    parameters = {
      server           = "day2.node.consul"
      share            = "/"
      mountPermissions = "777"
    }
    mount_options = {
      fs_type = "nfs"
    }
  },
  {
    name      = "nexus"
    plugin_id = "nfs"
    volume_id = "nexus"
    capabilities = [
      {
        access_mode     = "single-node-writer"
        attachment_mode = "file-system"
      }
    ]
    parameters = {
      server           = "day2.node.consul"
      share            = "/"
      mountPermissions = "777"
    }
    mount_options = {
      fs_type = "nfs"
    }
  },
]

jobs = [
  {
    path = "./attachments/nexus-db.nomad.hcl"
  },
  {
    path = "./attachments/nexus.nomad.hcl"
    var_sets = [
      {
        name = "metrics_auth_header"
        # bWV0cmljczpQQHNzdzByZA== is the base64 encoding of "metrics:P@ssw0rd"
        value_string = "Basic bWV0cmljczpQQHNzdzByZA=="
      },
    ]
  },
]
