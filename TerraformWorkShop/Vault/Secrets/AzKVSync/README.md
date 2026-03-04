Terraform resources to manage KV-V2 secret backends

```powershell
$repoDir=git rev-parse --show-toplevel
$childPath="TerraformWorkShop/Vault/Secrets/AzKVSync"
Set-Location -Path (Join-Path -Path $repoDir -ChildPath $childPath)
az login
# sudo pwsh.exe -c "terraform init -upgrade";
# terraform apply ...
```