### Requirements
#### Permission
- Ensure Vault ACL policy `nomad-workload-identity` is ready (e.g. secret path permissions in Day1 `Update ACL policy in Vault`)  
[TerraformWorkShop/Vault/policy/terraform.tfvars](../../TerraformWorkShop/Vault/policy/terraform.tfvars)
```powershell
$repoDir=git rev-parse --show-toplevel
$childPath="TerraformWorkShop/Vault/policy/"
Set-Location -Path (Join-Path -Path $repoDir -ChildPath $childPath)
sudo pwsh.exe -c "terraform init -upgrade";
terraform apply --auto-approve
```

### Config Consul JWT auth for nomad
```powershell
$credential = Get-Credential -Message "credential to login vault" -UserName "000"
$env:VAULT_ADDR = "https://vault.day1.sololab"
vault login -no-print -method=ldap username=$($credential.UserName) password=$($credential.GetNetworkCredential().Password)

$repoDir=git rev-parse --show-toplevel
$childPath="TerraformWorkShop/Consul/Auth/JWT"
Set-Location -Path (Join-Path -Path $repoDir -ChildPath $childPath)
sudo pwsh.exe -c "terraform init -upgrade";
terraform apply --auto-approve
```