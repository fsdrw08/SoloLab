Deploy Loki by podman quadlet + podman kube play
### Requirements
#### Network
- Ensure External DNS record for `loki.day2.sololab` is ready  
[TerraformWorkShop/PowerDNS/zones](../../../TerraformWorkShop/PowerDNS/zones/terraform.tfvars)
```powershell
$repoDir=git rev-parse --show-toplevel
$childPath="TerraformWorkShop/PowerDNS/zones/"
terraform -chdir="$(Join-Path -Path $repoDir -ChildPath $childPath)" apply -auto-approve
```
- Ensure Internal DNS record for `loki.day2.sololab` is ready  
[TerraformWorkShop/etcd/skydns](../../../TerraformWorkShop/etcd/skydns/terraform.tfvars)
```powershell
$repoDir=git rev-parse --show-toplevel
$childPath="TerraformWorkShop/etcd/skydns/"
terraform -chdir="$(Join-Path -Path $repoDir -ChildPath $childPath)" apply -auto-approve
```
#### Middleware
- Ensure External L4 loadbalancer for `loki.day2.sololab` is ready  
[TerraformWorkShop/VyOS/HAProxy](../../../TerraformWorkShop/VyOS/HAProxy/terraform.tfvars)
```powershell
$repoDir=git rev-parse --show-toplevel
$childPath="TerraformWorkShop/VyOS/HAProxy/"
terraform -chdir="$(Join-Path -Path $repoDir -ChildPath $childPath)" apply -auto-approve
```
#### Workload
- Ensure container image `grafana/loki` had synced to image server  
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
- Ensure MinIO IAM policy and credential for Loki is ready  
[TerraformWorkShop/MinIO/Day1](../../../TerraformWorkShop/MinIO/Day1/terraform.tfvars)
```powershell
$repoDir=git rev-parse --show-toplevel
$childPath="TerraformWorkShop/MinIO/Day1/"
terraform -chdir="$(Join-Path -Path $repoDir -ChildPath $childPath)" apply -auto-approve
```

### Deploy Loki podman quadlet workload
```powershell
$repoDir=git rev-parse --show-toplevel
$childPath="TerraformWorkShop/Quadlet/loki"
Set-Location -Path (Join-Path -Path $repoDir -ChildPath $childPath)
sudo pwsh.exe -c "terraform init -upgrade";
terraform apply --auto-approve
```