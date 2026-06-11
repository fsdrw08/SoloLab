### Requirements
#### Network
- Ensure external DNS record for `atlantis.day4.sololab` is ready  
[TerraformWorkShop/PowerDNS/zones](../../../../TerraformWorkShop/PowerDNS/zones/terraform.tfvars)
```powershell
$repoDir=git rev-parse --show-toplevel
$childPath="TerraformWorkShop/PowerDNS/zones/"
terraform -chdir="$(Join-Path -Path $repoDir -ChildPath $childPath)" apply -auto-approve
```

- Ensure internal DNS record for `atlantis.day4.sololab` is ready 
[TerraformWorkShop/etcd/skydns](../../../../TerraformWorkShop/etcd/skydns/terraform.tfvars)
```powershell
$repoDir=git rev-parse --show-toplevel
$childPath="TerraformWorkShop/etcd/skydns/"
terraform -chdir="$(Join-Path -Path $repoDir -ChildPath $childPath)" apply -auto-approve
```

#### Workload
- Ensure container image `runatlantis/atlantis` had synced to image registry  
[LocalWorkShop/Sync-OCIImage/Day4.jsonc](../../../../LocalWorkShop/Sync-OCIImage/Day4.jsonc)
```powershell
$repoDir=git rev-parse --show-toplevel
$childPath="LocalWorkShop/Sync-OCIImage"
Set-Location -Path (Join-Path -Path $repoDir -ChildPath $childPath)
$proxy="127.0.0.1:7890"; $env:HTTP_PROXY=$proxy; $env:HTTPS_PROXY=$proxy; $env:NO_PROXY="sololab,consul"
.\Sync-OCIImage.ps1 -PrivateRegistry "zot.day1.sololab" -SyncProfile "Day4.jsonc" # -Upload $false
# .\Sync-OCIImage.ps1 -PrivateRegistry "zot.day1.sololab" -SyncProfile "Day4.jsonc" -LocalStore "D:/Users/Public/Downloads/containers" -Upload $false
```

#### Middleware
- Ensure external L4 loadbalancer for `atlantis.day4.sololab` is ready  
[TerraformWorkShop/VyOS/HAProxy](../../../../TerraformWorkShop/VyOS/HAProxy/terraform.tfvars)
```powershell
$repoDir=git rev-parse --show-toplevel
$childPath="TerraformWorkShop/VyOS/HAProxy/"
terraform -chdir="$(Join-Path -Path $repoDir -ChildPath $childPath)" apply -auto-approve
```

#### Security
- Ensure atlantis related credential in vault is ready
[TerraformWorkShop/Vault/Secrets/Others/terraform.tfvars](../../../../TerraformWorkShop/Vault/Secrets/Others/terraform.tfvars)
```powershell
$repoDir=git rev-parse --show-toplevel
$childPath="TerraformWorkShop/Vault/Secrets/Others/"
terraform -chdir="$(Join-Path -Path $repoDir -ChildPath $childPath)" apply -auto-approve
```

### Deploy atlantis nomad job
```powershell
$repoDir=git rev-parse --show-toplevel
$childPath="TerraformWorkShop/Nomad/Jobs/atlantis/"
Set-Location -Path (Join-Path -Path $repoDir -ChildPath $childPath)
sudo pwsh.exe -c "[System.Environment]::SetEnvironmentVariable('CONSUL_HTTP_TOKEN',`"$env:CONSUL_HTTP_TOKEN`"); terraform -chdir=`"$(Join-Path -Path $repoDir -ChildPath $childPath)`" init -upgrade"; 

terraform -chdir="$(Join-Path -Path $repoDir -ChildPath $childPath)" apply -auto-approve
```

### To cleanup juicefs volume:
```powershell
# check volume uuid
etcdctl --insecure-skip-tls-verify --endpoints=https://etcd-0.day1.sololab:2379 --user=root:P@ssw0rd get /juicefs/atlantis-data/ --prefix=true
$uuid=read-host "juicefs volume uuid"

# get root ca cert path in this repo
$repoDir=git rev-parse --show-toplevel
$childPath="TerraformWorkShop/TLS/RootCA/root.crt"
$rootCaCertPath=Join-Path -Path $repoDir -ChildPath $childPath
# delete juicefs volume meta data in etcd
juicefs destroy etcd://juicefs:juicefs@etcd-0.day1.sololab:443/juicefs/atlantis-data/_?cacert=$($rootCaCertPath) $uuid

# delete juicefs volume chunk data in dufs
$credential="admin:admin"
curl.exe -X DELETE -k https://dufs.day1.sololab/webdav/csi-atlantis-data/ --user $credential
```