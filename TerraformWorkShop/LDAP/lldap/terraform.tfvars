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
    user_id = "001"
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
      "001"
    ]
  },
  {
    iac_id       = "9d1dbb70"
    display_name = "app-vault-user"
    members = [
      "admin",
      "001",
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
      "001",
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
      "001",
    ]
  },
  {
    iac_id       = "e91c1a23"
    display_name = "app-consul-auto_config"
    members = [
      "admin",
      "001"
    ]
  },
  {
    iac_id       = "c2826a4f"
    display_name = "app-consul-user"
    members = [
      "admin",
      "001"
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
    iac_id       = "542b0c36"
    display_name = "app-consul-readonly"
    members = [
      "001"
    ]
  },
  {
    iac_id       = "091a24fe"
    display_name = "app-nomad-user"
    members = [
      "admin",
      "001"
    ]
  },
  {
    iac_id       = "ca4dde60"
    display_name = "app-nomad-admin"
    members = [
      "admin"
    ]
  },
  {
    iac_id       = "a4019ca3"
    display_name = "app-grafana-user"
    members = [
      "admin",
      "001",
    ]
  },
  {
    iac_id       = "a3d0b5af"
    display_name = "app-grafana-app-grafana-root"
    members = [
      "admin",
    ]
  },
  {
    iac_id       = "20a3d418"
    display_name = "app-grafana-admin"
    members = [

    ]
  },
]

