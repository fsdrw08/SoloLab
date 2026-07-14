### Update ACL policy in Vault
This action might run once every month, as vault token will expire after 1 month.
```powershell
$repoDir=git rev-parse --show-toplevel
$childPath="TerraformWorkShop/Vault/policy"
Set-Location -Path (Join-Path -Path $repoDir -ChildPath $childPath)
sudo pwsh.exe -c "terraform init -upgrade";
terraform apply --auto-approve
```