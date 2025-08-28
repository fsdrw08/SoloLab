prov_nomad = {
  address     = "https://nomad.day1.sololab"
  skip_verify = true
}

prov_pdns = {
  api_key    = "powerdns"
  server_url = "https://pdns-auth.day0.sololab"
}

dns_records = [
  {
    zone = "day2.sololab."
    name = "traefik.day2.sololab."
    type = "CNAME"
    ttl  = 86400
    records = [
      "traefik-day2.service.consul."
    ]
  },
]
