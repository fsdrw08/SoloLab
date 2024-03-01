ref: [Identity: entities and groups](https://developer.hashicorp.com/vault/tutorials/auth-methods/identity?variants=vault-deploy%3Aselfhosted#create-an-external-group)

this TF module is used to config ldap auth backend and bind ldap group 
into vault external identity group, it makes the RBAC management in 
ldap site, 

which means, this module will: 
1. config ldap auth backend
2. define what can a group member do in vault (by vault policy resource),
3. let vault know the group alias in ldap server (bind vault external identity group and ldap group together),


then you can create a ldap group in ldap server, add ldap user in this ldap group, after that, use the ldap user
credential login to vault, and you can get the permission which describe in vault policy 