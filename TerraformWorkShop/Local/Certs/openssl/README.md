### Create self-sign Root CA
Generate private key
```powershell
# https://memo.open-code.club/OpenSSL/%E3%81%AF%E3%81%98%E3%82%81%E3%81%AB/%E5%85%AC%E9%96%8B%E9%8D%B5%E6%9A%97%E5%8F%B7%E3%81%AE%E9%8D%B5%E3%83%9A%E3%82%A2.html
openssl genpkey -algorithm RSA `
    -pkeyopt rsa_keygen_bits:2048 `
    -pkeyopt rsa_keygen_pubexp:65537 `
    -aes-256-cbc `
    -pass pass:changeit `
    -outform PEM `
    -out openssl-ca.key 
# have a check
openssl pkey -text -noout -in openssl-ca.key
```

Create Root CA cert
```powershell
openssl req -x509 `
    -config openssl-ca-test.conf `
    -key openssl-ca.key `
    -out openssl-ca.crt

# have a check
openssl x509 -in openssl-ca.crt -text -noout
```

### or create root ca cert and private key together
- ref:
  - [如何使用 OpenSSL 簽發中介 CA](https://blog.davy.tw/posts/use-openssl-to-sign-intermediate-ca/)
```powershell
$keyout="openssl-root-ca.key"
$RootCertOut="openssl-root-ca.crt"
openssl req -x509 `
    -config openssl-ca.conf `
    -days 3652 `
    -keyout $keyout `
    -out $RootCertOut
```

### sign a cert with CA
```powershell
$csr="..\csr\sololab_v1_ica1_v1.csr"
$CACert="openssl-root-ca.crt"
$CAKey="openssl-root-ca.key"
$CertOut="Intermediate_CA1_v1.crt"
openssl x509 -req `
    -days 1095 `
    -extfile openssl-ca.conf -extensions v3_ca `
    -in $csr `
    -CA $CACert -CAkey $CAKey -CAcreateserial -passin pass:changeit `
    -out $CertOut
```

### merge the cert 
```powershell
$bundle=".\sololab_v1_ica1_v1.crt"
Get-Content .\*.crt | Set-Content -Path $bundle -Force
```