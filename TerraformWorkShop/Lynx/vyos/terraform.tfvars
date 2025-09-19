# https://github.com/Clivern/terraform-provider-lynx?tab=readme-ov-file#usage
prov_lynx_api_url = "https://lynx.vyos.sololab/api/v1"

# one user can be assigned to multi teams
users = [
  {
    iac_id   = "2472d46b"
    name     = "sa-tf-agent"
    email    = "sa-tf-agent@mail.sololab"
    password = "terraform"
  }
]

# one team can be assigned to multi projects.
# but one project can only have one team
teams = [
  {
    iac_id = "decd4296"
    name   = "DevOps"
    members = [
      "sa-tf-agent"
    ]
  }
]

projects = [
  {
    iac_id = "7994303c"
    name   = "SoloLab-VyOS"
    team   = "DevOps"
    environments = [
      {
        iac_id   = "cd10b85e"
        name     = "PowerDNS"
        username = "terraform"
        secret   = "terraform"
      },
      {
        iac_id   = "de0d6901"
        name     = "HAProxy"
        username = "terraform"
        secret   = "terraform"
      },
    ]
  }
]
