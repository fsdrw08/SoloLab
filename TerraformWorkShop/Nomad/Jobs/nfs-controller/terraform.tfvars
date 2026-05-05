prov_nomad = {
  address     = "https://nomad.day2.sololab"
  skip_verify = true
}

jobs = [
  {
    path = "./attachments/nfs-controller.nomad.hcl"
  },
]
