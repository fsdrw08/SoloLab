### Requirements
#### Network
- Ensure external DNS record for `otf.day4.sololab` is ready
(PowerDNS in VyOS [TerraformWorkShop/PowerDNS/zones](../../TerraformWorkShop/PowerDNS/zones/terraform.tfvars))
```powershell
$repoDir=git rev-parse --show-toplevel
$childPath="TerraformWorkShop/PowerDNS/zones/"
terraform -chdir="$(Join-Path -Path $repoDir -ChildPath $childPath)" apply -auto-approve
```
- Ensure internal DNS record for `otf.day4.sololab` is ready  
[TerraformWorkShop/etcd/skydns](../../TerraformWorkShop/etcd/skydns/terraform.tfvars)
```powershell
$repoDir=git rev-parse --show-toplevel
$childPath="TerraformWorkShop/etcd/skydns/"
terraform -chdir="$(Join-Path -Path $repoDir -ChildPath $childPath)" apply -auto-approve
```
#### Workload
- Ensure OTF container image `docker.io/leg100/otfd:0.6.3` had synced to image server  
[LocalWorkShop/Sync-OCIImage/Day4.jsonc](../../LocalWorkShop/Sync-OCIImage/Day4.jsonc)
```powershell
$repoDir=git rev-parse --show-toplevel
$childPath="LocalWorkShop/Sync-OCIImage"
Set-Location -Path (Join-Path -Path $repoDir -ChildPath $childPath)
$proxy="127.0.0.1:7890"; $env:HTTP_PROXY=$proxy; $env:HTTPS_PROXY=$proxy; $env:NO_PROXY="sololab,consul"
.\Sync-OCIImage.ps1 -PrivateRegistry "zot.day1.sololab" -SyncProfile "Day4.jsonc" # -Upload $false
# .\Sync-OCIImage.ps1 -PrivateRegistry "zot.day1.sololab" -SyncProfile "Day4.jsonc" -LocalStore "D:/Users/Public/Downloads/containers" -Upload $false
```
#### Middleware
- Ensure external L4 loadbalancer for `otf.day4.sololab` is ready
(haproxy in VyOS [TerraformWorkShop/VyOS/HAProxy](../../TerraformWorkShop/VyOS/HAProxy/terraform.tfvars))
```powershell
$repoDir=git rev-parse --show-toplevel
$childPath="TerraformWorkShop/VyOS/HAProxy/"
terraform -chdir="$(Join-Path -Path $repoDir -ChildPath $childPath)" apply -auto-approve
```
#### Security
- Ensure OTF related LDAP entities is ready  
[TerraformWorkShop/ldap/lldap](../../TerraformWorkShop/ldap/lldap/terraform.tfvars)
```powershell
$repoDir=git rev-parse --show-toplevel
$childPath="TerraformWorkShop/ldap/lldap/"
terraform -chdir="$(Join-Path -Path $repoDir -ChildPath $childPath)" apply -auto-approve
```
- Ensure OTF related LDAP group entity in LDAP server had synced to OIDC server 
[TerraformWorkShop/Vault/Auth/LDAP](../../TerraformWorkShop/Vault/Auth/LDAP/terraform.tfvars)
```powershell
$repoDir=git rev-parse --show-toplevel
$childPath="TerraformWorkShop/Vault/Auth/LDAP/"
terraform -chdir="$(Join-Path -Path $repoDir -ChildPath $childPath)" apply -auto-approve
```
- Ensure OTF related OIDC client config is ready  
[TerraformWorkShop/Vault/Identity/OIDC](../../TerraformWorkShop/Vault/Identity/OIDC/terraform.tfvars)
```powershell
$repoDir=git rev-parse --show-toplevel
$childPath="TerraformWorkShop/Vault/Identity/OIDC/"
terraform -chdir="$(Join-Path -Path $repoDir -ChildPath $childPath)" apply -auto-approve
```
- Ensure OTF related secrets (include postgresql) in Vault is ready  
[TerraformWorkShop/Vault/Secrets/Others](../../TerraformWorkShop/Vault/Secrets/Others/terraform.tfvars)
```powershell
$repoDir=git rev-parse --show-toplevel
$childPath="TerraformWorkShop/Vault/Secrets/Others/"
terraform -chdir="$(Join-Path -Path $repoDir -ChildPath $childPath)" apply -auto-approve
```

### Deploy OTF nomad job
```powershell
$credential = Get-Credential -Message "credential to login vault" -UserName "000"
$env:VAULT_ADDR = "https://vault.day1.sololab"
vault login -no-print -method=ldap username=$($credential.UserName) password=$($credential.GetNetworkCredential().Password)

$env:CONSUL_HTTP_TOKEN = $(vault kv get -format=json -mount=kvv2_consul token-role-tf_backend | jq.exe .data.data.token).Replace('"', '')
$env:NOMAD_TOKEN = $(vault kv get -format=json -mount=kvv2_nomad token-management | jq.exe .data.data.token).Replace('"', '')

$repoDir=git rev-parse --show-toplevel
$childPath="TerraformWorkShop/Nomad/Jobs/otf/"
Set-Location -Path (Join-Path -Path $repoDir -ChildPath $childPath)
sudo pwsh.exe -c "[System.Environment]::SetEnvironmentVariable('CONSUL_HTTP_TOKEN',`"$env:CONSUL_HTTP_TOKEN`"); terraform -chdir=`"$(Join-Path -Path $repoDir -ChildPath $childPath)`" init -upgrade"; 
terraform -chdir="$(Join-Path -Path $repoDir -ChildPath $childPath)" apply -auto-approve
```