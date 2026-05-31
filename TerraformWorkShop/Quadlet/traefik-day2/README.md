Deploy Traefik to Day2 VM
### Requirements
#### Network
- Ensure external DNS record for `traefik.day2.sololab` is ready  
[TerraformWorkShop/PowerDNS/zones](../../../TerraformWorkShop/PowerDNS/zones/terraform.tfvars)
```powershell
$repoDir=git rev-parse --show-toplevel
$childPath="TerraformWorkShop/PowerDNS/zones/"
terraform -chdir="$(Join-Path -Path $repoDir -ChildPath $childPath)" apply -auto-approve
```
- Ensure internal DNS record for `traefik.day2.sololab` is ready  
[TerraformWorkShop/etcd/skydns](../../../TerraformWorkShop/etcd/skydns/terraform.tfvars)
```powershell
$repoDir=git rev-parse --show-toplevel
$childPath="TerraformWorkShop/etcd/skydns/"
terraform -chdir="$(Join-Path -Path $repoDir -ChildPath $childPath)" apply -auto-approve
```
#### Middleware
- Ensure external L4 loadbalancer for `traefik.day2.sololab` is ready
(haproxy in VyOS [TerraformWorkShop/VyOS/HAProxy](../../../TerraformWorkShop/VyOS/HAProxy/terraform.tfvars))
```powershell
$repoDir=git rev-parse --show-toplevel
$childPath="TerraformWorkShop/VyOS/HAProxy/"
terraform -chdir="$(Join-Path -Path $repoDir -ChildPath $childPath)" apply -auto-approve
```
#### Workload
- Ensure Traefik container image `library/traefik` had synced to image server
[LocalWorkShop/Sync-OCIImage/Day2.jsonc](../../../LocalWorkShop/Sync-OCIImage/Day2.jsonc)
```powershell
$repoDir=git rev-parse --show-toplevel
$childPath="LocalWorkShop/Sync-OCIImage"
Set-Location -Path (Join-Path -Path $repoDir -ChildPath $childPath)
$proxy="127.0.0.1:7890"; $env:HTTP_PROXY=$proxy; $env:HTTPS_PROXY=$proxy; $env:NO_PROXY="sololab,consul"
.\Sync-OCIImage.ps1 -PrivateRegistry "zot.day1.sololab" -SyncProfile "Day4.jsonc" # -Upload $false
# .\Sync-OCIImage.ps1 -PrivateRegistry "zot.day1.sololab" -SyncProfile "Day4.jsonc" -LocalStore "D:/Users/Public/Downloads/containers" -Upload $false
```
#### Security
- Ensure day2 wild card cert `*.day2.sololab` and consul service wild card cert `*.service.consul` in vault is ready  
[TerraformWorkShop/Vault/Secrets/PKI/certs/terraform.tfvars](../../../TerraformWorkShop/Vault/Secrets/PKI/certs/terraform.tfvars)
```powershell
$repoDir=git rev-parse --show-toplevel
$childPath="TerraformWorkShop/Vault/Secrets/PKI/certs/"
terraform apply -chdir="$(Join-Path -Path $repoDir -ChildPath $childPath)"  -auto-approve
```
- Ensure consul token `consul_dns` with proper ACL policy for traefik is ready  
[TerraformWorkShop/Consul/ACL/terraform.tfvars](../../../TerraformWorkShop/Consul/ACL/terraform.tfvars)
```powershell
$repoDir=git rev-parse --show-toplevel
$childPath="TerraformWorkShop/Consul/ACL/"
terraform apply -chdir="$(Join-Path -Path $repoDir -ChildPath $childPath)"  -auto-approve
```

### Deploy Traefik podman container
```powershell
$credential = Get-Credential -Message "credential to login vault" -UserName "000"
$env:VAULT_ADDR = "https://vault.day1.sololab"
vault login -no-print -method=ldap username=$($credential.UserName) password=$($credential.GetNetworkCredential().Password)

$repoDir=git rev-parse --show-toplevel
$childPath="TerraformWorkShop/Quadlet/traefik-day2"
Set-Location -Path (Join-Path -Path $repoDir -ChildPath $childPath)
sudo pwsh.exe -c "terraform init -upgrade";
terraform apply --auto-approve
```