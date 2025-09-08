prov_nomad = {
  address     = "https://nomad.day1.sololab"
  skip_verify = true
}

# dynamic_host_volumes = [
#   {
#     name = "traefik"
#     capability = {
#       access_mode = "single-node-writer"
#     }
#   }
# ]

csi_volumes = [
  {
    name      = "nomad-traefik-acme"
    plugin_id = "nfs"
    volume_id = "traefik-acme"
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
      server = "192.168.255.10"
      share  = "/"
    }
    mount_options = {
      fs_type = "nfs"
    }
  }
]

