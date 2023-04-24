variable "ldap_config" {
    type = map(object({
        # connection
        url = string
        starttls = bool
        insecure_tls = bool
        certificate = string
        # Binding - Authenticated Search
        binddn = string
        bindpass = string
        userdn = string
        userattr = string
        # Group Membership Resolution
        groupfilter = string
        groupdn = string
        groupattr = string
    }))
}