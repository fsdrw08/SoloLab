This module is used to create a root CA in hashicorp vault, and import exist ca cert key bundle from exist file,  
root CA in vault contains vault mount path, pki secret backend configs(url, crl configs, role, issuer), 
ref: 
- [vault-ca-demo/root_ca.t](https://github.com/stvdilln/vault-ca-demo/blob/52d03797168fdff075f638e57362ac8c4946cc94/root_ca.tf#L101)
- [Build Certificate Authority (CA) in Vault with an offline Root](https://developer.hashicorp.com/vault/tutorials/secrets-management/pki-engine-external-ca)
- [Build your own certificate authority (CA)](https://developer.hashicorp.com/vault/tutorials/secrets-management/pki-engine)
- [mount.tf](https://github.com/arpanrecme/vault_monorepo/blob/main/codified_vault/pki/mount.tf)

### Pre-request
Prepare a root cert key bundle first, see [../../../../TLS/RootCA/](../../../../TLS/RootCA)


### apply the whole tf resource 
#### Import root cert key bundle
To create offline root ca, in [terraform.tfvars](./terraform.tfvars) uncomment 
```h
ref_cert_bundle_path = "../../../../TLS/RootCA/RootCA_bundle.pem"
```

and comment 
```h
ref_cert_bundle_path           = ""
```

then save the file.

Run terraform apply
```powershell
terraform plan
terraform apply --auto-approve
```

#### Revert the code change
After apply, delete the root cert key bundle cert file in  [../../../../TLS/RootCA/](../../../../TLS/RootCA), revert above change:  
comment out
```h
ref_cert_bundle_path = "../../../../TLS/RootCA/RootCA_bundle.pem"
```

and uncomment 
```h
ref_cert_bundle_path           = ""
```

then save the file.

Run terraform apply again
```powershell
terraform plan
terraform apply --auto-approve
```


### have a check with the csr of intermediate ca
- ref: 
  - [Step 3: Generate ICA1 in vault](https://developer.hashicorp.com/vault/tutorials/secrets-management/pki-engine-external-ca#step-3-generate-ica1-in-vault)
  - [You probably don’t need jq in PowerShell](https://ncox.dev/blog/jq-powershell/)

Run in powershell
```powershell
terraform show -json | ConvertFrom-Json | Select-Object -ExpandProperty values | Select-Object -ExpandProperty root_module | Select-Object -ExpandProperty resources | Where-Object {$_.type -eq "vault_pki_secret_backend_intermediate_cert_request" -and $_.name -eq "sololab_v1_ica1_v1"} | Select-Object -ExpandProperty values | Select-Object -ExpandProperty csr | Out-File -Encoding utf8 -FilePath .\csr\sololab_v1_ica1_v1.csr
```

### have a check with the cert chain
have a check
```powershell
$VAULT_ADDR="https://vault.day1.sololab"
curl -k --request LIST $VAULT_ADDR/pki/issuers
Invoke-RestMethod -URI $VAULT_ADDR/v1/sololab-pki/v1/ica1/v1/ca/pem | step certificate inspect
Invoke-RestMethod -URI $VAULT_ADDR/v1/sololab-pki/v1/ica2/v1/ca_chain | step certificate inspect
```
run in linux
```shell
VAULT_ADDR="http://vault.day1.sololab:8200" 
curl -s $VAULT_ADDR/v1/sololab-pki/v1/ica1/v1/ca/pem | openssl crl2pkcs7 -nocrl -certfile /dev/stdin | openssl pkcs7 -print_certs -noout
curl -s $VAULT_ADDR/v1/sololab-pki/v1/ica1/v1/ca/ca_chain | openssl crl2pkcs7 -nocrl -certfile /dev/stdin | openssl pkcs7 -print_certs -noout
curl -s $VAULT_ADDR/v1/sololab-pki/v1/ica2/v1/ca/pem | openssl crl2pkcs7 -nocrl -certfile  /dev/stdin  | openssl pkcs7 -print_certs -noout
curl -s $VAULT_ADDR/v1/sololab-pki/v1/ica2/v1/ca_chain | openssl crl2pkcs7 -nocrl -certfile  /dev/stdin  | openssl pkcs7 -print_certs -noout
curl -s $VAULT_ADDR/v1/sololab-pki/v1/ica2/v1/ca/pem | openssl x509 -in /dev/stdin -noout -text | grep "X509v3 extensions"  -A 13
curl -s $VAULT_ADDR/v1/sololab-pki/v1/ica2/v1/ca_chain | openssl crl2pkcs7 -nocrl -certfile  /dev/stdin  | openssl pkcs7 -print_certs -noout
```

have a check
ref: https://developer.hashicorp.com/vault/docs/commands#vault_cacert
```powershell
$env:VAULT_ADDR="https://vault.day1.sololab"
$env:VAULT_TOKEN="hvs.pqibSbWZDHGmY2ZBlT0IHKXG"
$env:VAULT_CACERT=join-path (git rev-parse --show-toplevel) -ChildPath "KubeWorkShop\Traefik\conf\root_ca.crt"
vault login
vault auth list

# https://developer.hashicorp.com/vault/docs/secrets/pki/considerations#role-based-access
$env:VAULT_ADDR="https://vault.day1.sololab"
$env:VAULT_TOKEN="hvs.pqibSbWZDHGmY2ZBlT0IHKXG"
$ca1="sololab-pki/v1/ica1/v1"
$ca2="sololab-pki/v1/ica2/v1"
curl -k --header "X-Vault-Token: $env:VAULT_TOKEN" $env:VAULT_ADDR/v1/$ca1/ca/pem
curl -k --header "X-Vault-Token: $env:VAULT_TOKEN" $env:VAULT_ADDR/v1/$ca2/ca_chain
# ca issuer
Invoke-RestMethod -SkipCertificateCheck -URI $env:VAULT_ADDR/v1/$ca2/ca | step certificate inspect
curl -k --header "X-Vault-Token: $env:VAULT_TOKEN" $env:VAULT_ADDR/v1/$ca2/ca
curl -k --header "X-Vault-Token: $env:VAULT_TOKEN" $env:VAULT_ADDR/v1/$ca1/config/urls | ConvertFrom-Json
curl -k --header "X-Vault-Token: $env:VAULT_TOKEN" $env:VAULT_ADDR/v1/$ca1/config/crl  | ConvertFrom-Json  
curl -k --header "X-Vault-Token: $env:VAULT_TOKEN" $env:VAULT_ADDR/v1/$ca1/crl/pem
curl -k --header "X-Vault-Token: $env:VAULT_TOKEN" $env:VAULT_ADDR/v1/$ca1/crl/rotate | ConvertFrom-Json  
curl -k --header "X-Vault-Token: $env:VAULT_TOKEN" --request LIST $env:VAULT_ADDR/v1/$ca1/issuers | ConvertFrom-Json  
curl -k --header "X-Vault-Token: $token" --request LIST $env:VAULT_ADDR/v1/$ca1/roles | ConvertFrom-Json  
curl -k --header "X-Vault-Token: $token" $env:VAULT_ADDR/v1/$ca1/ocsp/

curl http://cacerts.digicert.com/DigiCertTLSHybridECCSHA3842020CA1-1.crt
```

### different and relations between backend_role and backend_issuer in pki
via AI

在HashiCorp Vault的PKI后端中，backend role和backend issuer有以下区别和关系：
#### 区别:
- 定义和功能:  
backend issuer：是PKI后端中用于定义证书签发相关配置的实体，它主要负责指定证书签发的参数和规则，如签名算法、证书链等。例如，可以配置一个issuer来指定使用SHA256WithRSA算法进行证书签发。  
backend role：则是定义了客户端在请求签发证书时所允许使用的参数和限制条件。比如可以设置role允许请求IP SANs、允许的域名、证书的有效期等。

- 配置内容:  
backend issuer：配置内容主要涉及证书签发的技术细节，如issuer_ref用于指定签发者引用，revocation_signature_algorithm用于指定吊销签名算法等。  
backend role：配置内容更侧重于对证书请求的约束和限制，如allow_ip_sans用于允许或禁止IP SANs，allowed_domains用于指定允许的域名列表，ttl和max_ttl用于设置证书的有效期等。

#### 关系:
- 相互依赖:  
在证书签发过程中，backend issuer和backend role是相互依赖的。只有同时配置了issuer和role，客户端才能根据role中定义的参数和限制条件，通过issuer所指定的签发规则来请求签发证书。例如，要从根CA签发证书，就需要配置根CA的issuer接口和相应的role参数。
- 共同作用于证书签发:  
当客户端发起证书签发请求时，Vault会根据请求中指定的role来验证请求的参数是否符合role中定义的限制条件，若符合则会使用role关联的issuer来按照issuer的配置规则进行证书签发。比如，一个role允许请求problemofnetwork.com域及其子域的证书，并且关联了一个特定的issuer，那么客户端在符合role条件的情况下，就可以通过该issuer来获取相应域名的证书。
