prov_lynx = {
  api_url = "https://lynx.vyos.sololab"
  api_key = ""
}

users = [{
  iac_id   = "123"
  name     = "user1"
  email    = "user1"
  password = "user1"
  member_of = [
    "team1",
    "team2"
  ]
}]
