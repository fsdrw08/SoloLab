# https://registry.terraform.io/providers/elastic-infra/ldap/latest/docs/resources/object
resource "ldap_object" "system" {
  dn             = "uid=system,cn=sysaccounts,cn=etc,dc=infra,dc=sololab"
  object_classes = ["account", "simplesecurityobject"]
  attributes = [
    { uid = "system" },
    { userPassword = "P@ssw0rd" },
    { passwordExpirationTime = "20380119031407Z" },
    { nsIdleTimeout = "0" }
  ]
}