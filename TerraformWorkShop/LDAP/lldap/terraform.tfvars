prov_lldap = {
  http_url                 = "https://lldap.day0.sololab"
  ldap_url                 = "ldaps://lldap.day0.sololab"
  insecure_skip_cert_check = true
  username                 = "admin"
  password                 = "P@ssw0rd"
  base_dn                  = "dc=root,dc=sololab"
}

users = [
  {
    user_id = "readonly"
    email   = "readonly@mail.sololab"
    # uncomment below filed when apply this resource in first time
    password     = "readonly"
    display_name = "readonly"
  },
  {
    user_id = "user1"
    email   = "user1@mail.sololab"
    # uncomment below filed when apply this resource in first time
    password     = "P@ssw0rd"
    display_name = "user1"
  }
]

# to generate iac_id:
# powershell: new-guid
# linux: uuidgen
groups = [
  {
    iac_id       = "02999e39"
    display_name = "sso_allow"
    members = [
      "admin",
      "user1"
    ]
  },
  {
    iac_id       = "751b1e41"
    display_name = "app-vault-admin"
    members = [
      "admin",
    ]
  },
  {
    iac_id       = "94a5e552"
    display_name = "app-minio-user"
    members = [
      "admin",
      "user1",
    ]
  },
  {
    iac_id       = "4d620c35"
    display_name = "app-minio-admin"
    members = [
      "admin",
    ]
  },
  {
    iac_id       = "0c31450b"
    display_name = "app-minio-readwrite"
    members = [
      "user1",
    ]
  },
  {
    iac_id       = "e91c1a23"
    display_name = "app-consul-auto_config"
    members = [
      "admin",
      "user1"
    ]
  },
  {
    iac_id       = "c2826a4f"
    display_name = "app-consul-user"
    members = [
      "admin",
      "user1"
    ]
  },
  {
    iac_id       = "0f898573"
    display_name = "app-consul-admin"
    members = [
      "admin"
    ]
  },
  {
    iac_id       = "ca4dde60"
    display_name = "app-nomad-admin"
    members = [
      "admin"
    ]
  },
]

