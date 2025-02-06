This terraform resources are used to config Vault as jwt auth provider to consul.

There are 2 scenarios while consul require jwt auth:
## 1. Auto Config
Used to distribute secure properties such as Access Control List (ACL) tokens, TLS certificates, gossip encryption keys, and other configuration settings to all Consul agents in a datacenter.  
ref: [Automate Consul agent security with auto config](https://developer.hashicorp.com/consul/tutorials/archive/docker-compose-auto-config)  

After apply resource in this dir, login vault ui with user who is a member of group `App-Consul-Auto_Config`(in this project, the group and user are managed in LDAP server, and use the [LDAP](../../LDAP/) terraform resource to sync them to vault), put meta data key value: `consul_agent: <host name>` in user it self's entry,  
then run a query in vault ui `API Explorer` to get the tocken
![](api_explorer.png)

## 2. User Auth
Used to auth user access into consul via jwt token  
ref: https://github.com/gitrgoliveira/vault-consul-auth/blob/356687425d9ee5bbdc03134e372e9b16a5791a07/01.demo.sh