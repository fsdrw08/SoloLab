Deploy grafana podman container quadlet + podman kube
### Requirements
#### Network
- Ensure External DNS record for `grafana.day2.sololab` is ready  
[TerraformWorkShop/PowerDNS/zones](../../../TerraformWorkShop/PowerDNS/zones/terraform.tfvars)
```powershell
$repoDir=git rev-parse --show-toplevel
$childPath="TerraformWorkShop/PowerDNS/zones/"
terraform -chdir="$(Join-Path -Path $repoDir -ChildPath $childPath)" apply -auto-approve
```
- Ensure internal DNS record for `grafana.day2.sololab` is ready  
[TerraformWorkShop/etcd/skydns](../../../TerraformWorkShop/etcd/skydns/terraform.tfvars)
```powershell
$repoDir=git rev-parse --show-toplevel
$childPath="TerraformWorkShop/etcd/skydns/"
terraform -chdir="$(Join-Path -Path $repoDir -ChildPath $childPath)" apply -auto-approve
```
#### Workload
- Ensure Grafana container image `grafana/grafana` had synced to image server  
[LocalWorkShop/Sync-OCIImage/Day2.jsonc](../../../LocalWorkShop/Sync-OCIImage/Day2.jsonc)
```powershell
$repoDir=git rev-parse --show-toplevel
$childPath="LocalWorkShop/Sync-OCIImage"
Set-Location -Path (Join-Path -Path $repoDir -ChildPath $childPath)
$proxy="127.0.0.1:7890"; $env:HTTP_PROXY=$proxy; $env:HTTPS_PROXY=$proxy; $env:NO_PROXY="sololab,consul"
.\Sync-OCIImage.ps1 -PrivateRegistry "zot.day1.sololab" -SyncProfile "Day2.jsonc" # -Upload $false
# .\Sync-OCIImage.ps1 -PrivateRegistry "zot.day1.sololab" -SyncProfile "Day2.jsonc" -LocalStore "D:/Users/Public/Downloads/containers" -Upload $false
```
- Ensure Grafana related plugins had synced to web file server  
[LocalWorkShop/SyncTo-Dufs/Day2.jsonc](../../../LocalWorkShop/SyncTo-Dufs/Day2.jsonc)
```powershell
$repoDir=git rev-parse --show-toplevel
$childPath="LocalWorkShop/SyncTo-Dufs"
Set-Location -Path (Join-Path -Path $repoDir -ChildPath $childPath)
$proxy="127.0.0.1:7890"; $env:HTTP_PROXY=$proxy; $env:HTTPS_PROXY=$proxy; $env:NO_PROXY="sololab"
.\SyncTo-Dufs.ps1 -SyncProfile "Day2.jsonc" # -Upload $false
# .\SyncTo-Dufs.ps1 -SyncProfile "Day2.jsonc" -LocalStore "D:/Users/Public/Downloads/bin" -Upload $false
``` 
#### Middleware
- Ensure external L4 loadbalancer for `grafana.day2.sololab` is ready  
[TerraformWorkShop/VyOS/HAProxy](../../../TerraformWorkShop/VyOS/HAProxy/terraform.tfvars)
```powershell
$repoDir=git rev-parse --show-toplevel
$childPath="TerraformWorkShop/VyOS/HAProxy/"
terraform -chdir="$(Join-Path -Path $repoDir -ChildPath $childPath)" apply -auto-approve
```
#### Security
- Ensure Grafana related LDAP entities is ready  
[TerraformWorkShop/ldap/lldap](../../../TerraformWorkShop/ldap/lldap/terraform.tfvars)
```powershell
$repoDir=git rev-parse --show-toplevel
$childPath="TerraformWorkShop/ldap/lldap/"
terraform -chdir="$(Join-Path -Path $repoDir -ChildPath $childPath)" apply -auto-approve
```
- Ensure Grafana related LDAP group entity in LDAP server had synced to OIDC server  
[TerraformWorkShop/Vault/Auth/LDAP](../../../TerraformWorkShop/Vault/Auth/LDAP/)
```powershell
$repoDir=git rev-parse --show-toplevel
$childPath="TerraformWorkShop/Vault/Auth/LDAP/"
terraform -chdir="$(Join-Path -Path $repoDir -ChildPath $childPath)" apply -auto-approve
```
- Ensure Grafana related OIDC client config is ready  
[TerraformWorkShop/Vault/Identity/OIDC](../../../TerraformWorkShop/Vault/Identity/OIDC/terraform.tfvars)
```powershell
$repoDir=git rev-parse --show-toplevel
$childPath="TerraformWorkShop/Vault/Identity/OIDC/"
terraform -chdir="$(Join-Path -Path $repoDir -ChildPath $childPath)" apply -auto-approve
```
- Ensure Grafana related admin credential in Vault is ready  
[TerraformWorkShop/Vault/Secrets/Others](../../../TerraformWorkShop/Vault/Secrets/Others/terraform.tfvars)
```powershell
$repoDir=git rev-parse --show-toplevel
$childPath="TerraformWorkShop/Vault/Secrets/Others/"
terraform -chdir="$(Join-Path -Path $repoDir -ChildPath $childPath)" apply -auto-approve
```

### Deploy Grafana podman quadlet workload
```powershell
$credential = Get-Credential -Message "credential to login vault" -UserName "000"
$env:VAULT_ADDR = "https://vault.day1.sololab"
vault login -no-print -method=ldap username=$($credential.UserName) password=$($credential.GetNetworkCredential().Password)

$repoDir=git rev-parse --show-toplevel
$childPath="TerraformWorkShop/Quadlet/grafana/"
Set-Location -Path (Join-Path -Path $repoDir -ChildPath $childPath)
sudo pwsh.exe -c "terraform init -upgrade";
terraform apply --auto-approve
```