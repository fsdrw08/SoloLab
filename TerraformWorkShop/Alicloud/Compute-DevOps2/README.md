```powershell
$keyPath="$home\.ssh\gitlab2.pem"
$port="8122"
terraform output --raw private_key | out-file -Path $keyPath -Encoding utf8 -Force
ssh -i $keyPath root@$(terraform output --raw public_ip) -p $port
```
```
tnc 8.219.240.35 -port 8122
```