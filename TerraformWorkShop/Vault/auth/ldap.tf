# ldap auth
resource "vault_ldap" "ldap" {
    # connection
    url = var.ldap_url
    starttls = var.starttls
    insecure_tls = var.insecure_tls
    certificate = var.certificate
    # Binding - Authenticated Search
    binddn = var.binddn
    bindpass = var.bindpass
    userdn = var.userdn
    userattr = var.userattr
    # Group Membership Resolution
    groupfilter = var.groupfilter
    groupdn = var.groupdn
    groupattr = var.groupattr
}