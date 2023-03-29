keycloak mapping:
https://min.io/docs/minio/linux/operations/external-iam/configure-keycloak-identity-management.html#configure-minio-for-keycloak-identity-management
```
LDAP group -> KC Realm roles
KC\realm\Clients\client scopes\mapper
```

Set minio alias
```powershell
$alias="sololab"
$url="https://minio.infra.sololab/"
$rootUser="minio"
$rootPassword="password"

mc config host list
mc config host add --insecure $alias $url $rootUser $rootPassword
mc admin info $alias --insecure --debug
mc admin logs $alias --insecure --debug

mc mb sololab/test --insecure --debug
```

Set minio oidc
```powershell
$alias="sololab"
$idpName="keycloak"
$clientID="minio"
$clientSecret="hsRtNv7paVEcACt8Axtvnwu9ZHXhUDAb"
$configURL="https://keycloak.infra.sololab/realms/freeipa-realm/.well-known/openid-configuration"
$scopes="openid,email"

# https://min.io/docs/minio/linux/operations/external-iam/configure-keycloak-identity-management.html#configure-minio-for-keycloak-authentication
mc admin idp openid add $alias $idpName `
   client_id=$clientID `
   client_secret=$clientSecret `
   config_url=$configURL `
   display_name=$idpName `
   scopes=$scopes `
   --insecure --debug

mc admin service restart sololab --insecure --debug
```

debug keycloak json token
https://min.io/docs/minio/linux/operations/external-iam/configure-keycloak-identity-management.html
```powershell
curl -k `
    -d "client_id=minio" `
    -d "client_secret=hsRtNv7paVEcACt8Axtvnwu9ZHXhUDAb" `
    -d "grant_type=password" `
    -d "username=keycloak" `
    -d "password=password" `
    https://keycloak.infra.sololab/realms/freeipa-realm/protocol/openid-connect/token
```