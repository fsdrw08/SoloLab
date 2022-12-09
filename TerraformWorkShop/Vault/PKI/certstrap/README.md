### Create self-sign Root CA
```powershell
certstrap init `
    --passphrase "changeit" `
    --organization "Sololab" `
    --organizational-unit "Sololab Org" `
    --country "CN" `
    --province "GD" `
    --locality "Foshan" `
    --common-name "Sololab Root"
```

### sign a cert with CA
```powershell
certstrap sign `
    --passphrase "changeit" `
    --expires "3 year" `
    --csr ..\csr\Sololab_Org_v1_ICA1_v1.csr `
    --cert .\out\Intermediate_CA1_v1.crt `
    --intermediate `
    --CA "Sololab Root" `
    "Intermediate CA1 v1"
```


### merge the cert 
```powershell
$certs=".\out\*.crt"
$bundle=".\out\Sololab_org_v1_ica1_v1.crt"
Get-Content $certs | Set-Content -Path $bundle -Force
```