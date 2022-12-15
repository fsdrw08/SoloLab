### create root ca from step cli
ref:
- https://smallstep.com/docs/step-cli/reference/certificate#commands
```powershell
$csr="..\csr\Sololab_Org_v1_ICA1_v1.csr"
$crt=".\step-root-ca.crt"
$key=".\step-root-ca.key"
$passwordFile=".\password.txt"
$tpl=".\step-root-ca.tpl"
step certificate create "Sololab Root CA" `
    $crt $key `
    --password-file $passwordFile `
    --template $tpl `
    --not-after 87648h `
    --kty RSA `
    --size 2048

# have a check
step certificate inspect step-ca.crt
```

### sign csr
https://smallstep.com/docs/step-cli/reference/certificate/sign
```powershell
$csr="..\csr\Sololab_Org_v1_ICA1_v1.csr"
$crt=".\step-root-ca.crt"
$key=".\step-root-ca.key"
$passwordFile=".\password.txt"
step certificate sign $csr $crt $key `
    --password-file $passwordFile `
    --profile intermediate-ca `
    --path-len=-1 `
    --bundle `
    | Set-Content -Path .\Sololab_org_v1_ica1_v1.crt
```