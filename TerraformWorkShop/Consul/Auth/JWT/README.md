## Config Consul jwt auth method

These resources are used to config how to "login" consul by jwt token, currently there are 2 jwt token provider available: nomad, vault(deprecated)  

### Nomad
Use case:
- Let nomad workload registry service / get kv data from consul
- ref: [Configure Consul for services workload identities](https://developer.hashicorp.com/nomad/tutorials/integrate-consul/consul-acl#configure-consul-for-services-workload-identities)
- ref: https://github.com/tristanmorgan/nomad-test/blob/a622eb3a72c3688b4c9bb77853b457bb549930fe/terraform/nomad_workloads.tf

Procedure:
1. Create role in [../../ACL/](../../ACL/) first
2. apply resource in this dir


### Vault
Use case: 
- Consul auto config:  
  - Deprecated, use auto_encrypt instead, just don't want to prepare the jwt token manually
  - Used to distribute secure properties such as Access Control List (ACL) tokens, TLS certificates, gossip encryption keys, and other configuration settings to all Consul agents in a datacenter
  - ref: https://developer.hashicorp.com/consul/docs/secure/auto-config/docker#introduction
- Consul user login:
  - Deprecated, use vault consul secret engine instead
  - Get token from vault, exchange the token into consul secret id in consul, login consul
  - ref: https://github.com/gitrgoliveira/vault-consul-auth/blob/356687425d9ee5bbdc03134e372e9b16a5791a07/consul.tf

Procedure:
1. Prepare vault jwt auth provider in [../../../Vault/Identity/JWT/](../../../Vault/Identity/JWT) first,  
2. apply the terraform resource in this dir,  
3. get jwt from vault
4. run below command, put jwt token content in to variable `$token`

```powershell
$env:CONSUL_HTTP_ADDR="https://consul.day1.sololab:8501"

$token="xxx"

curl.exe -k --request POST `
    --data "{`"AuthMethod`":`"vault-jwt`",`"BearerToken`":`"$token`"}" `
    $env:CONSUL_HTTP_ADDR/v1/acl/login

```