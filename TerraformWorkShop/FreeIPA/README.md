```powershell
$env:http_proxy="127.0.0.1:7890"
$env:https_proxy="127.0.0.1:7890"
terraform init
```