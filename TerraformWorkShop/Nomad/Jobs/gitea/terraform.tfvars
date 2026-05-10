prov_nomad = {
  address     = "https://nomad.day2.sololab"
  skip_verify = true
}

dynamic_host_volumes = [
  {
    name = "hvol-gitea-db"
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
      uid = 26
      gid = 26
    }
  },
]

csi_volumes = [
  {
    name      = "csi-gitea-data"
    plugin_id = "nfs"
    volume_id = "csi-gitea-data"
    capabilities = [
      {
        access_mode     = "multi-node-multi-writer"
        attachment_mode = "file-system"
      }
    ]
    parameters = {
      server           = "day3.node.consul"
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
    path = "./attachments/gitea-db.nomad.hcl"
  },
  {
    path = "./attachments/gitea.nomad.hcl"
    var_sets = [
      {
        name                = "config"
        value_template_path = "./attachments/app.ini"
      },
    ]
  },
  # {
  #   path = "./attachments/gitea-admin.nomad.hcl"
  #   var_sets = [
  #     {
  #       name                = "config"
  #       value_template_path = "./attachments/app.ini"
  #     },
  #     {
  #       name                = "admin_script"
  #       value_template_path = "./attachments/gitea-admin.sh"
  #     },
  #   ]
  # }
]
