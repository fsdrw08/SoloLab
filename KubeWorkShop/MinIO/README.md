keycloak

https://keycloak.infra.sololab/realms/freeipa-realm/.well-known/openid-configuration

minio

hsRtNv7paVEcACt8Axtvnwu9ZHXhUDAb


```powershell
mc config host list

mc config host add --insecure sololab https://minio.infra.sololab/ minio password

mc config host add sololab http://127.0.0.1:9000/ minio password

mc admin info sololab --insecure --debug

mc admin logs sololab --insecure --debug

mc mb sololab/test --insecure 

$alias="sololab"
$idpName="keycloak"
$clientID="minio"
$clientSecret="hsRtNv7paVEcACt8Axtvnwu9ZHXhUDAb"
$configURL="https://keycloak.infra.sololab/realms/freeipa-realm/.well-known/openid-configuration"
$scopes="email,profile"

mc admin idp openid add $alias $idpName `
   client_id=$clientID `
   client_secret=$clientSecret `
   config_url=$configURL `
   display_name=$idpName `
   scopes=$scopes `
   redirect_uri_dynamic="on" `
   --insecure --debug

mc admin service restart sololab --insecure --debug
```

https://min.io/docs/minio/linux/operations/external-iam/configure-keycloak-identity-management.html
```powershell
curl -k `
    -d "client_id=minio" `
    -d "client_secret=hsRtNv7paVEcACt8Axtvnwu9ZHXhUDAb" `
    -d "grant_type=password" `
    -d "username=carefree1" `
    -d "password=password" `
    https://keycloak.infra.sololab/realms/freeipa-realm/protocol/openid-connect/token
```