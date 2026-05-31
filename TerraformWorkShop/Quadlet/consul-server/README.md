### Requirements
#### Network3
- Ensure external DNS record for `consul.day2.sololab` is ready  
[TerraformWorkShop/PowerDNS/zones](../../../TerraformWorkShop/PowerDNS/zones/terraform.tfvars)
```powershell
$repoDir=git rev-parse --show-toplevel
$childPath="TerraformWorkShop/PowerDNS/zones/"
terraform -chdir="$(Join-Path -Path $repoDir -ChildPath $childPath)" apply -auto-approve
```
- Ensure internal DNS record for `consul.day2.sololab` is ready  
[TerraformWorkShop/etcd/skydns](../../../TerraformWorkShop/etcd/skydns/terraform.tfvars)
```powershell
$repoDir=git rev-parse --show-toplevel
$childPath="TerraformWorkShop/etcd/skydns/"
terraform -chdir="$(Join-Path -Path $repoDir -ChildPath $childPath)" apply -auto-approve
```
#### Workload3
- Ensure Consul container image `hashicorp/consul` had synced to image server
[LocalWorkShop/Sync-OCIImage/Day2.jsonc](../../../LocalWorkShop/Sync-OCIImage/Day2.jsonc)
```powershell
$repoDir=git rev-parse --show-toplevel
$childPath="LocalWorkShop/Sync-OCIImage"
Set-Location -Path (Join-Path -Path $repoDir -ChildPath $childPath)
$proxy="127.0.0.1:7890"; $env:HTTP_PROXY=$proxy; $env:HTTPS_PROXY=$proxy; $env:NO_PROXY="sololab,consul"
.\Sync-OCIImage.ps1 -PrivateRegistry "zot.day1.sololab" -SyncProfile "Day4.jsonc" # -Upload $false
# .\Sync-OCIImage.ps1 -PrivateRegistry "zot.day1.sololab" -SyncProfile "Day4.jsonc" -LocalStore "D:/Users/Public/Downloads/containers" -Upload $false
```
#### Middleware3
- Ensure external L4 loadbalancer for `consul.day2.sololab` is ready
(haproxy in VyOS [TerraformWorkShop/VyOS/HAProxy](../../../TerraformWorkShop/VyOS/HAProxy/terraform.tfvars))
```powershell
$repoDir=git rev-parse --show-toplevel
$childPath="TerraformWorkShop/VyOS/HAProxy/"
terraform -chdir="$(Join-Path -Path $repoDir -ChildPath $childPath)" apply -auto-approve
```
#### Security3
- Ensure consul cert `consul.day2.sololab` is ready  
[TerraformWorkShop/Vault/Secrets/PKI/certs](../../../TerraformWorkShop/Vault/Secrets/PKI/certs/terraform.tfvars)
```powershell
$repoDir=git rev-parse --show-toplevel
$childPath="TerraformWorkShop/Vault/Secrets/PKI/certs/"
terraform apply -chdir="$(Join-Path -Path $repoDir -ChildPath $childPath)"  -auto-approve
```

- Ensure consul secret: init management token `token-init_management` and gossip encryption key `key-gossip_encryption` in Vault are ready  
[TerraformWorkShop/Vault/Secrets/Consul/main.tf](../../../TerraformWorkShop/Vault/Secrets/Consul/main.tf)
```powershell
$repoDir=git rev-parse --show-toplevel
$childPath="TerraformWorkShop/Vault/Secrets/Consul/"
terraform apply -chdir="$(Join-Path -Path $repoDir -ChildPath $childPath)"  -auto-approve
```

#### Deploy Consul server podman container
[TerraformWorkShop/Quadlet/consul-server](../../../TerraformWorkShop/Quadlet/consul-server)
```powershell
$credential = Get-Credential -Message "credential to login vault" -UserName "000"
$env:VAULT_ADDR = "https://vault.day1.sololab"
vault login -no-print -method=ldap username=$($credential.UserName) password=$($credential.GetNetworkCredential().Password)

$repoDir=git rev-parse --show-toplevel
$childPath="TerraformWorkShop/Quadlet/consul-server"
Set-Location -Path (Join-Path -Path $repoDir -ChildPath $childPath)
sudo pwsh.exe -c "terraform init -upgrade";
terraform apply --auto-approve
```