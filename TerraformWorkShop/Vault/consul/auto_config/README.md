This terraform resource is used to make vault for consul auto_config, 
ref: [Automate Consul agent security with auto config](https://developer.hashicorp.com/consul/tutorials/archive/docker-compose-auto-config#configure-vault-to-generate-jwts)

After apply resource in this dir, login vault ui with user who is a member of group `App-Consul-Auto_Config`(in this project, the group and user are managed in LDAP server, and use the [LDAP](../../LDAP/) terraform resource to sync them to vault), put meta data key value: `consul_agent: <host name>` in user it self's entry, 
then run a query in vault ui `API Explorer` to get the tocken
![](api_explorer.png)