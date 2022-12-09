apply terraform 

ref: 
- [Build Certificate Authority (CA) in Vault with an offline Root](https://developer.hashicorp.com/vault/tutorials/secrets-management/pki-engine-external-ca)
- [mount.tf](https://github.com/arpanrecme/vault_monorepo/blob/main/codified_vault/pki/mount.tf)

### apply intermediate ca cert
From terraform module
```powershell
terraform plan
terraform apply
```

### have a check with the csr of intermediate ca
- ref: 
  - [Step 3: Generate ICA1 in vault](https://developer.hashicorp.com/vault/tutorials/secrets-management/pki-engine-external-ca#step-3-generate-ica1-in-vault)
  - [You probably don’t need jq in PowerShell](https://ncox.dev/blog/jq-powershell/)

Run in powershell
```powershell
terraform show -json | ConvertFrom-Json | Select-Object -ExpandProperty values | Select-Object -ExpandProperty root_module | Select-Object -ExpandProperty resources | Where-Object {$_.type -eq "vault_pki_secret_backend_intermediate_cert_request" -and $_.name -eq "sololab_org_v1_ica1_v1"} | Select-Object -ExpandProperty values | Select-Object -ExpandProperty csr | Out-File -Encoding utf8 -FilePath .\csr\Sololab_Org_v1_ICA1_v1.csr
```

### have a check with the cert chain
have a check
```powershell
$VAULT_ADDR="http://192.168.255.31:8200"
Invoke-RestMethod -URI $VAULT_ADDR/v1/sololab-org/v1/ica1/v1/ca/pem | step certificate inspect
Invoke-RestMethod -URI $VAULT_ADDR/v1/sololab-org/v1/ica2/v1/ca_chain | step certificate inspect
```
run in linux
```shell
VAULT_ADDR="http://192.168.255.31:8200" && curl -s  $VAULT_ADDR/v1/sololab-org/v1/ica1/v1/ca/pem | openssl crl2pkcs7 -nocrl -certfile /dev/stdin | openssl pkcs7 -print_certs -noout
VAULT_ADDR="http://192.168.255.31:8200" && curl -s  $VAULT_ADDR/v1/sololab-org/v1/ica1/v1/ca/ca_chain | openssl crl2pkcs7 -nocrl -certfile /dev/stdin | openssl pkcs7 -print_certs -noout
```

### Generate ICA2 in vault
add [sololab_org_ica2.tf](sololab_org_ica2.tf), then apply
```powershell
terraform apply
```
have a check, run in linux
```shell
$VAULT_ADDR="http://192.168.255.31:8200"
curl -s $VAULT_ADDR/v1/sololab-org/v1/ica2/v1/ca/pem | openssl crl2pkcs7 -nocrl -certfile  /dev/stdin  | openssl pkcs7 -print_certs -noout
curl -s $VAULT_ADDR/v1/sololab-org/v1/ica2/v1/ca_chain | openssl crl2pkcs7 -nocrl -certfile  /dev/stdin  | openssl pkcs7 -print_certs -noout
curl -s $VAULT_ADDR/v1/sololab-org/v1/ica2/v1/ca/pem | openssl x509 -in /dev/stdin -noout -text | grep "X509v3 extensions"  -A 13
curl -s $VAULT_ADDR/v1/sololab-org/v1/ica2/v1/ca_chain | openssl crl2pkcs7 -nocrl -certfile  /dev/stdin  | openssl pkcs7 -print_certs -noout
```

### Create PKI role rooted in ICA2
