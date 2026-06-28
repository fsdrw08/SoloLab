Config Nomad OIDC login and add management token
### Requirements
#### Security
- Ensure Nomad related LDAP group entity is ready  
[TerraformWorkShop/LDAP/LLDAP](../../../TerraformWorkShop/LDAP/LLDAP/terraform.tfvars)
```powershell
$repoDir=git rev-parse --show-toplevel
$childPath="TerraformWorkShop/LDAP/LLDAP/"
terraform -chdir="$(Join-Path -Path $repoDir -ChildPath $childPath)" apply -auto-approve
```
- Ensure LDAP user and group had already sync to Vault  
[TerraformWorkShop/Vault/Auth/LDAP](../../../TerraformWorkShop/Vault/Auth/LDAP/main.tf)
```powershell
$repoDir=git rev-parse --show-toplevel
$childPath="TerraformWorkShop/Vault/Auth/LDAP/"
terraform -chdir="$(Join-Path -Path $repoDir -ChildPath $childPath)" apply -auto-approve
```
- Ensure `nomad` OIDC client in Vault is ready  
[TerraformWorkShop/Vault/Identity/OIDC](../../TerraformWorkShop/Vault/Identity/OIDC/terraform.tfvars)
```powershell
$repoDir=git rev-parse --show-toplevel
$childPath="TerraformWorkShop/Vault/Identity/OIDC/"
terraform -chdir="$(Join-Path -Path $repoDir -ChildPath $childPath)" apply -auto-approve
```
- copy nomad root token from Day2 VM
```shell
ssh Day2-FCOS
less /home/podmgr/.local/share/containers/storage/volumes/nomad-pvc/_data/server/nomad_token
```
- put this token into vault secret kvv2_nomad/token-management:
```powershell
$credential = Get-Credential -Message "credential to login vault" -UserName "000"
$env:VAULT_ADDR = "https://vault.day1.sololab"
vault login -no-print -method=ldap username=$($credential.UserName) password=$($credential.GetNetworkCredential().Password)

$env:NOMAD_TOKEN="<the token copy from Day2 VM>"
vault kv put -mount=kvv2_nomad token-management token=$env:NOMAD_TOKEN
```

### Config Nomad ACL policy and OIDC login
```powershell
$env:NOMAD_TOKEN = $(vault kv get -format=json -mount=kvv2_nomad token-management | jq.exe .data.data.token).Replace('"', '')

$repoDir=git rev-parse --show-toplevel
$childPath="TerraformWorkShop/Nomad/ACL"
Set-Location -Path (Join-Path -Path $repoDir -ChildPath $childPath)
sudo pwsh.exe -c "terraform init -upgrade";
terraform apply
```  