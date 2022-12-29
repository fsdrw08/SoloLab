resource "freeipa_dns_record" "vault" {
  zone_name = "infra.sololab."
  name = "vault"
  records = [ "192.168.255.31" ]
  type = "A"
}