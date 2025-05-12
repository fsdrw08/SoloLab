Terraform resources in this directory are used to Administer Consul access control tokens with Vault

ref: [Administer Consul access control tokens with Vault](https://developer.hashicorp.com/consul/tutorials/operate-consul/vault-consul-secrets)

These tf resources will:
1. Create vault consul secret backend
2. Create vault consul backend roles, specify policy hosting in consul,
e.g. some builtin policy `global-management`, `builtin/global-read-only`, check [consul/alc/built-in-policies](https://developer.hashicorp.com/consul/docs/security/acl/acl-policies#built-in-policies), bind the `vault-consul_backend-role` with `consul-policy`
3. Create vault policy to limit vault user retrieve consul token from vault, the policy assigned to some policy groups(the vault internal group), then link some vault external groups(which comes from LDAP in this case) to the policy group

After apply this tf resources, we only need to add user to the vault external groups (also ok to add user via LDAP, then sync the user, group and relationship to vault), then the user is able login to consul by the token which retrieve from vault api endpoint `/consul/creds/{role}`