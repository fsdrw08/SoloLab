```powershell
$keyPath="$home\.ssh\gitlab.pem"
$port="8022"
terraform output --raw private_key | out-file -Path $keyPath -Encoding utf8 -Force
ssh -o "StrictHostKeyChecking=no" -i $keyPath root@$(terraform output --raw public_ip) -p $port
```