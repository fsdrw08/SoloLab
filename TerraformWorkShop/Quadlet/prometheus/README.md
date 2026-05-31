Deploy Prometheus by terraform + podman quadlet + podman kube 
### Requirements
#### Network
- Ensure External DNS record for `prometheus.day2.sololab` is ready  
[TerraformWorkShop/PowerDNS/zones](../../../TerraformWorkShop/PowerDNS/zones)
```powershell
$repoDir=git rev-parse --show-toplevel
$childPath="TerraformWorkShop/PowerDNS/zones/"
terraform -chdir="$(Join-Path -Path $repoDir -ChildPath $childPath)" apply -auto-approve
```
- Ensure Internal DNS record for `prometheus.day2.sololab` is ready
[TerraformWorkShop/etcd/skydns](../../../TerraformWorkShop/etcd/skydns)
```powershell
$repoDir=git rev-parse --show-toplevel
$childPath="TerraformWorkShop/etcd/skydns/"
terraform -chdir="$(Join-Path -Path $repoDir -ChildPath $childPath)" apply -auto-approve
```
#### Middleware
- Ensure External L4 loadbalancer for `prometheus.day2.sololab` is ready
[TerraformWorkShop/VyOS/HAProxy](../../../TerraformWorkShop/VyOS/HAProxy/terraform.tfvars)
```powershell
$repoDir=git rev-parse --show-toplevel
$childPath="TerraformWorkShop/VyOS/HAProxy/"
terraform -chdir="$(Join-Path -Path $repoDir -ChildPath $childPath)" apply -auto-approve
```
#### Workload
- Ensure container image `prometheus/prometheus` had synced to image server  
[LocalWorkShop/Sync-OCIImage/Day2.jsonc](../../../LocalWorkShop/Sync-OCIImage/Day2.jsonc)
```powershell
$repoDir=git rev-parse --show-toplevel
$childPath="LocalWorkShop/Sync-OCIImage"
Set-Location -Path (Join-Path -Path $repoDir -ChildPath $childPath)
$proxy="127.0.0.1:7890"; $env:HTTP_PROXY=$proxy; $env:HTTPS_PROXY=$proxy; $env:NO_PROXY="sololab,consul"
.\Sync-OCIImage.ps1 -PrivateRegistry "zot.day1.sololab" -SyncProfile "Day2.jsonc" # -Upload $false
# .\Sync-OCIImage.ps1 -PrivateRegistry "zot.day1.sololab" -SyncProfile "Day2.jsonc" -LocalStore "D:/Users/Public/Downloads/containers" -Upload $false
```
#### Security
- Ensure vault token `token-prometheus_metrics` with proper permission for prometheus is ready  
[TerraformWorkShop/Vault/policy](../../../TerraformWorkShop/Vault/policy/terraform.tfvars)
```powershell
$repoDir=git rev-parse --show-toplevel
$childPath="TerraformWorkShop/Vault/policy/"
terraform -chdir="$(Join-Path -Path $repoDir -ChildPath $childPath)" apply -auto-approve
```
- Ensure consul token `prometheus` with proper ACL policy for prometheus is ready  
[TerraformWorkShop/Consul/ACL/terraform.tfvars](../../../TerraformWorkShop/Consul/ACL/terraform.tfvars)
```powershell
$repoDir=git rev-parse --show-toplevel
$childPath="TerraformWorkShop/Consul/ACL/"
terraform -chdir="$(Join-Path -Path $repoDir -ChildPath $childPath)" apply -auto-approve
```

### Deploy Prometheus podman workload
```powershell
$credential = Get-Credential -Message "credential to login vault" -UserName "000"
$env:VAULT_ADDR = "https://vault.day1.sololab"
vault login -no-print -method=ldap username=$($credential.UserName) password=$($credential.GetNetworkCredential().Password)

$repoDir=git rev-parse --show-toplevel
$childPath="TerraformWorkShop/Quadlet/prometheus"
Set-Location -Path (Join-Path -Path $repoDir -ChildPath $childPath)
sudo pwsh.exe -c "terraform init -upgrade";
terraform apply --auto-approve
```