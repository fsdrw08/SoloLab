prov_nomad = {
  address     = "https://nomad.day2.sololab"
  skip_verify = true
}

dynamic_host_volumes = [
  {
    name = "hvol-gitlab-db-main"
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
  {
    name = "hvol-gitlab-db-registry"
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
    name      = "csi-gitlab"
    plugin_id = "nfs"
    volume_id = "csi-gitlab"
    capabilities = [
      {
        access_mode     = "single-node-writer"
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
    path = "./attachments/gitlab-db.nomad.hcl"
  },
  {
    path = "./attachments/gitlab.nomad.hcl"
    var_sets = [
      {
        name                = "config"
        value_template_path = "./attachments/app.ini"
      },
    ]
  },
  # {
  #   path = "./attachments/gitlab-admin.nomad.hcl"
  #   var_sets = [
  #     {
  #       name                = "config"
  #       value_template_path = "./attachments/app.ini"
  #     },
  #     {
  #       name                = "admin_script"
  #       value_template_path = "./attachments/gitlab-admin.sh"
  #     },
  #   ]
  # }
]
