prov_nomad = {
  address     = "https://nomad.day1.sololab"
  skip_verify = true
}

dynamic_host_volumes = [
  {
    name = "test"
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
  }
]

# csi_volumes = [
#   {
#     name      = "nomad-grafana-data"
#     plugin_id = "nfs"
#     volume_id = "grafana-data"
#     capabilities = [
#       {
#         access_mode     = "multi-node-multi-writer"
#         attachment_mode = "file-system"
#       },
#       {
#         access_mode     = "single-node-writer"
#         attachment_mode = "file-system"
#       }
#     ]
#     parameters = {
#       server           = "192.168.255.10"
#       share            = "/"
#       mountPermissions = "777"
#     }
#     mount_options = {
#       fs_type = "nfs"
#     }
#   }
# ]

