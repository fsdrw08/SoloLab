apply terraform 

ref: 
- [Build Certificate Authority (CA) in Vault with an offline Root](https://developer.hashicorp.com/vault/tutorials/secrets-management/pki-engine-external-ca)
- [Build your own certificate authority (CA)](https://developer.hashicorp.com/vault/tutorials/secrets-management/pki-engine)
- [mount.tf](https://github.com/arpanrecme/vault_monorepo/blob/main/codified_vault/pki/mount.tf)

### apply the whole tf resource 
To create offline root ca, intermedia ca1 ca2 in vault, apply certs for 
```powershell
terraform plan
terraform apply --auto-approve -target="vault_mount.pki" -target="vault_mount.pki_ica1"
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
$VAULT_ADDR="https://vault.infra.sololab"
curl -k --request LIST $VAULT_ADDR/pki/issuers
Invoke-RestMethod -URI $VAULT_ADDR/v1/sololab-pki/v1/ica1/v1/ca/pem | step certificate inspect
Invoke-RestMethod -URI $VAULT_ADDR/v1/sololab-pki/v1/ica2/v1/ca_chain | step certificate inspect
```
run in linux
```shell
VAULT_ADDR="http://192.168.255.31:8200" 
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
$env:VAULT_ADDR="https://vault.infra.sololab"
$env:VAULT_TOKEN="hvs.pqibSbWZDHGmY2ZBlT0IHKXG"
$env:VAULT_CACERT=join-path (git rev-parse --show-toplevel) -ChildPath "KubeWorkShop\Traefik\conf\root_ca.crt"
vault login
vault auth list

# https://developer.hashicorp.com/vault/docs/secrets/pki/considerations#role-based-access
$env:VAULT_ADDR="https://vault.infra.sololab"
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