# prov_system = {
#   host     = "192.168.255.20"
#   port     = 22
#   user     = "core"
#   password = "P@ssw0rd"
# }

prov_nomad = {
  address     = "https://nomad.day1.sololab"
  skip_verify = true
}

jobs = [
  {
    path = "./attachments/nfs-ganesha.nomad.hcl"
    var_sets = [
      {
        name                = "config"
        value_template_path = "./attachments/ganesha.conf"
      },
    ]
  },
]
