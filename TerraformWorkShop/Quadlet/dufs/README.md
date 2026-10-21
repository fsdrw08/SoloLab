### Requirements
#### Network
- Ensure external DNS record for `dufs.day1.sololab` is ready  
[TerraformWorkShop/PowerDNS/zones](../../../TerraformWorkShop/PowerDNS/zones/terraform.tfvars)
```powershell
$repoDir=git rev-parse --show-toplevel
$childPath="TerraformWorkShop/PowerDNS/zones/"
terraform -chdir="$(Join-Path -Path $repoDir -ChildPath $childPath)" apply -auto-approve
```
- Ensure internal DNS record for `dufs.day1.sololab` is ready  
[TerraformWorkShop/etcd/skydns](../../../TerraformWorkShop/etcd/skydns/terraform.tfvars)
```powershell
$repoDir=git rev-parse --show-toplevel
$childPath="TerraformWorkShop/etcd/skydns/"
terraform -chdir="$(Join-Path -Path $repoDir -ChildPath $childPath)" apply -auto-approve
```
#### Workload
- Ensure Dufs container image `sigoden/dufs` had synced to image server
[LocalWorkShop/Sync-OCIImage/Day1.jsonc](../../../LocalWorkShop/Sync-OCIImage/Day1.jsonc)
```powershell
$repoDir=git rev-parse --show-toplevel
$childPath="LocalWorkShop/Sync-OCIImage"
Set-Location -Path (Join-Path -Path $repoDir -ChildPath $childPath)
$proxy="127.0.0.1:7890"; $env:HTTP_PROXY=$proxy; $env:HTTPS_PROXY=$proxy; $env:NO_PROXY="sololab,consul"
.\Sync-OCIImage.ps1 -PrivateRegistry "zot.day1.sololab" -SyncProfile "Day1.jsonc" # -Upload $false
# .\Sync-OCIImage.ps1 -PrivateRegistry "zot.day1.sololab" -SyncProfile "Day1.jsonc" -LocalStore "D:/Users/Public/Downloads/containers" -Upload $false
```
#### Middleware
- Ensure external L4 loadbalancer for `dufs.day1.sololab` is ready
(haproxy in VyOS [TerraformWorkShop/VyOS/HAProxy](../../../TerraformWorkShop/VyOS/HAProxy/terraform.tfvars))
```powershell
$repoDir=git rev-parse --show-toplevel
$childPath="TerraformWorkShop/VyOS/HAProxy/"
terraform -chdir="$(Join-Path -Path $repoDir -ChildPath $childPath)" apply -auto-approve
```
#### Security
- Ensure day1 wildcard cert `wildcard.day1` is ready  
[TerraformWorkShop/TLS/RootCA/terraform.tfvars](../../TLS/RootCA/terraform.tfvars)
```powershell
$repoDir=git rev-parse --show-toplevel
$childPath="TerraformWorkShop/TLS/RootCA/"
terraform apply -chdir="$(Join-Path -Path $repoDir -ChildPath $childPath)"  -auto-approve
```

- Ensure dufs secrets (`dir_xxx` in `app-dufs`) in Vault are ready  
[TerraformWorkShop/Vault/Secrets/Others/terraform.tfvars](../../../TerraformWorkShop/Vault/Secrets/Others/terraform.tfvars)
```powershell
$repoDir=git rev-parse --show-toplevel
$childPath="TerraformWorkShop/Vault/Secrets/Others/"
terraform apply -chdir="$(Join-Path -Path $repoDir -ChildPath $childPath)"  -auto-approve
```

#### Deploy Dufs server podman container
[TerraformWorkShop/Quadlet/dufs](../../../TerraformWorkShop/Quadlet/dufs)
```powershell
$credential = Get-Credential -Message "credential to login vault" -UserName "000"
$env:VAULT_ADDR = "https://vault.day1.sololab"
vault login -no-print -method=ldap username=$($credential.UserName) password=$($credential.GetNetworkCredential().Password)

$repoDir=git rev-parse --show-toplevel
$childPath="TerraformWorkShop/Quadlet/dufs"
Set-Location -Path (Join-Path -Path $repoDir -ChildPath $childPath)
sudo pwsh.exe -c "terraform init -upgrade";
terraform apply --auto-approve
```