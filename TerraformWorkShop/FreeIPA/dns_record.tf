resource "freeipa_dns_record" "traefik" {
  zone_name = "infra.sololab."
  name = "traefik"
  records = [ "192.168.255.32" ]
  type = "A"
}

resource "freeipa_dns_record" "ipa-ca" {
  zone_name = "infra.sololab."
  name = "ipa-ca"
  records = [ "192.168.255.31" ]
  type = "A"
}

resource "freeipa_dns_record" "pgadmin4" {
  zone_name = "infra.sololab."
  name = "pgadmin4"
  records = [ "192.168.255.32" ]
  type = "A"
}