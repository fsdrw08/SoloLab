run by cfssl
ref: 
- [cfssl-ca-tips](https://gist.github.com/tsaarni/557511180c49e9a3c281f5b67f25b093)
- [Certificate Authority with CFSSL](https://jite.eu/2019/2/6/ca-with-cfssl/)
- [Setting up CFSSL](https://propellered.com/posts/cfssl_setting_up/)
```powershell
cfssl gencert -initca ca-csr.json | cfssljson -bare out/ca
# then have a check
cfssl certinfo -cert .\out\ca.pem
```

### Sign ICA1 CSR with the offline Root CA
Run by cfssl
```powershell
cfssl sign -ca .\out\ca.pem `
           -ca-key .\out\ca-key.pem `
           -config cfssl-config.json `
           -profile intermediate `
           .\csr\Sololab_Org_v1_ICA1_v1.csr | cfssljson -bare out\Intermediate_CA1_v1
# have a check
cfssl certinfo -cert out\Intermediate_CA1_v1.pem
```