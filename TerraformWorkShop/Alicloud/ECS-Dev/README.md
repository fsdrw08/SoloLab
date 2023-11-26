```powershell
$user="admin"
$keyPath="$home\.ssh\gitlab-$user.pem"
$port="8022"
terraform output --raw "$($user)_private_key" | out-file -Path $keyPath -Encoding utf8 -Force
ssh -o "StrictHostKeyChecking=no" -i $keyPath $user@$(terraform output --raw public_ip) -p $port
```