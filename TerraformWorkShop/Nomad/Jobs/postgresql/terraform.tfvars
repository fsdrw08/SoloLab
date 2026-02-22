prov_nomad = {
  address     = "https://nomad.day1.sololab"
  skip_verify = true
}

jobs = [
  # {
  #   path = "./attachments/test-db.nomad.hcl"
  # },
  {
    path = "./attachments/gitea-db.nomad.hcl"
  },
]
