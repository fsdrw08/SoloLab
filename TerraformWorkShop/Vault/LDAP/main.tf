data "terraform_remote_state" "root_ca" {
  backend = "local"
  config = {
    path = "../../TLS/RootCA/terraform.tfstate"
  }
}

module "ldap_mgmt" {
  source = "../modules/ldap-mgmt"

  vault_ldap_auth = {
    sololab = {
      path         = "ldap"
      url          = "ldaps://lldap.service.consul"
      insecure_tls = false
      certificate  = data.terraform_remote_state.root_ca.outputs.root_cert_pem
      # freeipa
      # binddn       = "uid=system,cn=sysaccounts,cn=etc,dc=infra,dc=sololab"
      # bindpass     = var.ldap_bindpass
      # userdn       = "cn=users,cn=accounts,dc=infra,dc=sololab"
      # userattr     = "mail"
      # groupfilter  = "(&(objectClass=posixgroup)(cn=svc-vault-*)(member:={{.UserDN}}))"
      # groupdn      = "cn=groups,cn=accounts,dc=infra,dc=sololab"
      # groupattr    = "cn"

      # lldap
      binddn   = "cn=readonly,ou=people,dc=root,dc=sololab"
      bindpass = "readonly"
      userdn   = "ou=people,dc=root,dc=sololab"
      userattr = "uid"
      # userfilter = "({{.UserAttr}}={{.Username}})"
      # do not use upper case group name
      userfilter = "(&({{.UserAttr}}={{.Username}})(objectClass=person)(memberOf=cn=sso_allow,ou=groups,dc=root,dc=sololab))"
      groupdn    = "ou=groups,dc=root,dc=sololab"
      groupattr  = "cn"
      # groupfilter = "(|(memberUid={{.Username}})(member={{.UserDN}})(uniqueMember={{.UserDN}}))"
      groupfilter = "(&(objectClass=groupOfUniqueNames)(cn=app-*)(|(memberUid={{.Username}})(member={{.UserDN}})(uniqueMember={{.UserDN}})))"

    }
  }

  # vault policies
  vault_policies = {
    vault-root = {
      # policy_content = <<-EOT
      #   path "secret/*" 
      #   {
      #     capabilities = [ "create", "read", "update", "delete", "list", "patch" ]
      #   }
      #   # Manage identity
      #   path "identity/*"
      #   {
      #     capabilities = ["create", "read", "update", "delete", "list", "sudo"]
      #   }
      #   path "sys/health"
      #   {
      #     capabilities = ["read", "sudo"]
      #   }
      #   # Create and manage ACL policies broadly across Vault
      #   # List existing policies
      #   path "sys/policies/acl"
      #   {
      #     capabilities = ["list"]
      #   }
      #   # Create and manage ACL policies
      #   path "sys/policies/acl/*"
      #   {
      #     capabilities = ["create", "read", "update", "delete", "list", "sudo"]
      #   }
      #   # Enable and manage authentication methods broadly across Vault
      #   # Manage auth methods broadly across Vault
      #   path "auth/*"
      #   {
      #     capabilities = ["create", "read", "update", "delete", "list", "sudo"]
      #   }
      #   # Create, update, and delete auth methods
      #   path "sys/auth/*"
      #   {
      #     capabilities = ["create", "update", "delete", "sudo"]
      #   }
      #   # List auth methods
      #   path "sys/auth"
      #   {
      #     capabilities = ["read"]
      #   }
      #   # Enable and manage the key/value secrets engine at `secret/` path
      #   # List, create, update, and delete key/value secrets
      #   path "secret/*"
      #   {
      #     capabilities = ["create", "read", "update", "delete", "list", "sudo"]
      #   }
      #   # Manage secrets engines
      #   path "sys/mounts/*"
      #   {
      #     capabilities = ["create", "read", "update", "delete", "list", "sudo"]
      #   }
      #   # List existing secrets engines.
      #   path "sys/mounts"
      #   {
      #     capabilities = ["read"]
      #   }
      # EOT
      policy_content = <<-EOT
      path "*" {
          capabilities = ["create", "read", "update", "patch", "delete", "list", "sudo"]
      }
      EOT
    }
  }

  # groups
  vault_groups = {
    vault-root = {
      type     = "external"
      policies = ["vault-root"]
      alias = [
        {
          name     = "app-vault-root"
          ldap_key = "sololab"
        }
      ]
    }
    minio-default = {
      type     = "external"
      policies = ["default"]
      alias = [
        {
          name     = "app-minio-default"
          ldap_key = "sololab"
        }
      ]
    }
  }
}
