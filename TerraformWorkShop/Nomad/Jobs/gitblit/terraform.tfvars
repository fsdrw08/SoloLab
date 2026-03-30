prov_nomad = {
  address     = "https://nomad.day1.sololab"
  skip_verify = true
}

csi_volumes = [
  {
    name      = "gitblit"
    plugin_id = "nfs"
    volume_id = "gitblit"
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
  }
]

jobs = [
  {
    path = "./attachments/gitblit.nomad.hcl"
    var_sets = [
      {
        name                = "config"
        value_template_path = "./attachments/gitblit.properties"
      },
    ]
  },
]
