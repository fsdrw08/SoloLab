prov_nomad = {
  address     = "https://nomad.day1.sololab"
  skip_verify = true
}

dynamic_host_volumes = [
  {
    name = "traefik"
    capability = {
      access_mode = "single-node-writer"
    }
  }
]
