## Deprecated
consider use vault consul secret engine to manage consul acl token instead of jwt auth
[Consul secrets engine](https://developer.hashicorp.com/vault/docs/secrets/consul)

## Config Consul jwt auth method
ref: https://github.com/gitrgoliveira/vault-consul-auth/blob/356687425d9ee5bbdc03134e372e9b16a5791a07/consul.tf
1. prepare vault jwt auth provider in [../../Vault/consul/JWT_Auth/](../../Vault/consul/JWT_Auth/) first,  
2. apply the terraform resource in this dir,  
3. get jwt from vault
4. run below command, put jwt token content in to variable `$token`

```powershell
$env:CONSUL_HTTP_ADDR="https://consul.day0.sololab:8501"

$token="xxx"

curl.exe -k --request POST `
    --data "{`"AuthMethod`":`"vault-jwt`",`"BearerToken`":`"$token`"}" `
    $env:CONSUL_HTTP_ADDR/v1/acl/login

```