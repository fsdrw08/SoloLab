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
    member_of = [
      "lldap_strict_readonly",
    ]
  },
  {
    user_id      = "000"
    email        = "root@mail.sololab"
    password     = "P@ssw0rd"
    display_name = "root"
    member_of = [
      "lldap_admin",
      "sso_allow", # "02999e39" 
      # "app-sftpgo-prim-ignition", # c4bf67c5
      "app-zot-admin",          # "f8fddd0f"
      "app-vault-user",         # "9d1dbb70" 
      "app-vault-admin",        # "751b1e41" 
      "app-minio-user",         # "94a5e552" 
      "app-minio-admin",        # "4d620c35" 
      "app-consul-auto_config", # "e91c1a23" 
      "app-consul-user",        # "c2826a4f" 
      "app-consul-admin",       # "0f898573" 
      "app-nomad-user",         # "091a24fe" 
      "app-nomad-admin",        # "ca4dde60" 
      "app-grafana-user",       # "a4019ca3" 
      "app-grafana-root",       # "a3d0b5af" 
      "app-gitblit-user",       # "0d243b52" 
      "app-gitblit-admin",      # "ba1fd3a9" 
      "app-nexus-user",         # "90ebdcb1" 
      "app-nexus-admin",        # "044af468" 
    ]
  },
  {
    user_id = "001"
    email   = "user1@mail.sololab"
    # uncomment below filed when apply this resource in first time
    password     = "P@ssw0rd"
    display_name = "user1"
    member_of = [
      "sso_allow",              # "02999e39" 
      "app-vault-user",         # "9d1dbb70" 
      "app-minio-user",         # "94a5e552" 
      "app-minio-readwrite",    # "0c31450b" 
      "app-consul-auto_config", # "e91c1a23" 
      "app-consul-user",        # "c2826a4f" 
      "app-consul-readonly",    # "542b0c36" 
      "app-nomad-user",         # "091a24fe" 
      "app-grafana-user",       # "a4019ca3" 
      "app-nexus-user",         # "90ebdcb1" 
    ]
  }
]

# to generate iac_id:
#   powershell: new-guid
#   linux: uuidgen
groups = [
  {
    iac_id       = "02999e39"
    display_name = "sso_allow"
  },
  # {
  #   iac_id       = "c4bf67c5"
  #   display_name = "app-sftpgo-prim-ignition"
  # },
  {
    iac_id       = "f8fddd0f"
    display_name = "app-zot-admin"
  },
  {
    iac_id       = "9d1dbb70"
    display_name = "app-vault-user"
  },
  {
    iac_id       = "751b1e41"
    display_name = "app-vault-admin"
  },
  {
    iac_id       = "94a5e552"
    display_name = "app-minio-user"
  },
  {
    iac_id       = "4d620c35"
    display_name = "app-minio-admin"
  },
  {
    iac_id       = "0c31450b"
    display_name = "app-minio-readwrite"
  },
  {
    iac_id       = "e91c1a23"
    display_name = "app-consul-auto_config"
  },
  {
    iac_id       = "c2826a4f"
    display_name = "app-consul-user"
  },
  {
    iac_id       = "0f898573"
    display_name = "app-consul-admin"
  },
  {
    iac_id       = "542b0c36"
    display_name = "app-consul-readonly"
  },
  {
    iac_id       = "091a24fe"
    display_name = "app-nomad-user"
  },
  {
    iac_id       = "ca4dde60"
    display_name = "app-nomad-admin"
  },
  {
    iac_id       = "a4019ca3"
    display_name = "app-grafana-user"
  },
  {
    iac_id       = "a3d0b5af"
    display_name = "app-grafana-root"
  },
  {
    iac_id       = "20a3d418"
    display_name = "app-grafana-admin"
  },
  {
    iac_id       = "9114292a"
    display_name = "app-grafana-editor"
  },
  {
    iac_id       = "0d243b52"
    display_name = "app-gitblit-user"
  },
  {
    iac_id       = "ba1fd3a9"
    display_name = "app-gitblit-admin"
  },
  {
    iac_id       = "044af468"
    display_name = "app-nexus-admin"
  },
  {
    iac_id       = "90ebdcb1"
    display_name = "app-nexus-user"
  },
]

