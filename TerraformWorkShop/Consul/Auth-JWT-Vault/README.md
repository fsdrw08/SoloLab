1. prepare vault jwt auth provider in [../../Vault/OIDC/JWT-Consul/](../../Vault/OIDC/JWT-Consul/) first,  
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