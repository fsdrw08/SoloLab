### Requirements
#### Network
- Ensure external DNS record for `gitea.day4.sololab` is ready  
[TerraformWorkShop/PowerDNS/zones](../../../../TerraformWorkShop/PowerDNS/zones/terraform.tfvars)
```powershell
$repoDir=git rev-parse --show-toplevel
$childPath="TerraformWorkShop/PowerDNS/zones/"
terraform -chdir="$(Join-Path -Path $repoDir -ChildPath $childPath)" apply -auto-approve
```

- Ensure internal DNS record for `gitea.day4.sololab` is ready 
[TerraformWorkShop/etcd/skydns](../../../../TerraformWorkShop/etcd/skydns/terraform.tfvars)
```powershell
$repoDir=git rev-parse --show-toplevel
$childPath="TerraformWorkShop/etcd/skydns/"
terraform -chdir="$(Join-Path -Path $repoDir -ChildPath $childPath)" apply -auto-approve
```

#### Workload
- Ensure container image `gitea/gitea` had synced to image registry  
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
- Ensure external L4 loadbalancer for `gitea.day4.sololab` is ready  
[TerraformWorkShop/VyOS/HAProxy](../../../../TerraformWorkShop/VyOS/HAProxy/terraform.tfvars)
```powershell
$repoDir=git rev-parse --show-toplevel
$childPath="TerraformWorkShop/VyOS/HAProxy/"
terraform -chdir="$(Join-Path -Path $repoDir -ChildPath $childPath)" apply -auto-approve
```

- Ensure object storage related config is ready for Gitea is ready  
[TerraformWorkShop/MinIO/Day1/terraform.tfvars](../../../../TerraformWorkShop/MinIO/Day1/terraform.tfvars)
```powershell
$repoDir=git rev-parse --show-toplevel
$childPath="TerraformWorkShop/MinIO/Day1/"
terraform -chdir="$(Join-Path -Path $repoDir -ChildPath $childPath)" apply -auto-approve
```

- Ensure Redis ACL and related credential for Gitea is ready  
[TerraformWorkShop/Nomad/Jobs/redis/attachments-redis/acl.conf](../../../../TerraformWorkShop/Nomad/Jobs/redis/attachments-redis/acl.conf)
```powershell
$repoDir=git rev-parse --show-toplevel
$childPath="TerraformWorkShop/Nomad/Jobs/redis/"
terraform -chdir="$(Join-Path -Path $repoDir -ChildPath $childPath)" apply -auto-approve
```

- Ensure JuiceFS csi related backend credential (etcd for metadata storage, dufs for data storage) for Gitea is ready  
[TerraformWorkShop/etcd/IAM/terraform.tfvars](../../../../TerraformWorkShop/etcd/IAM/terraform.tfvars)
```powershell
$repoDir=git rev-parse --show-toplevel
$childPath="TerraformWorkShop/etcd/IAM/"
terraform -chdir="$(Join-Path -Path $repoDir -ChildPath $childPath)" apply -auto-approve
```

#### Security
- Ensure gitea postgresql credential in vault is ready
[TerraformWorkShop/Vault/Secrets/Others/terraform.tfvars](../../../../TerraformWorkShop/Vault/Secrets/Others/terraform.tfvars)
```powershell
$repoDir=git rev-parse --show-toplevel
$childPath="TerraformWorkShop/Vault/Secrets/Others/"
terraform -chdir="$(Join-Path -Path $repoDir -ChildPath $childPath)" apply -auto-approve
```

- Ensure gitea related LDAP entities is ready  
[TerraformWorkShop/ldap/lldap](../../../../TerraformWorkShop/ldap/lldap/terraform.tfvars)
```powershell
$repoDir=git rev-parse --show-toplevel
$childPath="TerraformWorkShop/ldap/lldap/"
terraform -chdir="$(Join-Path -Path $repoDir -ChildPath $childPath)" apply -auto-approve
```

- Ensure Gitea related LDAP group entity in LDAP server had synced to OIDC server  
[TerraformWorkShop/Vault/Auth/LDAP](../../../../TerraformWorkShop/Vault/Auth/LDAP/)
```powershell
$repoDir=git rev-parse --show-toplevel
$childPath="TerraformWorkShop/Vault/Auth/LDAP/"
terraform -chdir="$(Join-Path -Path $repoDir -ChildPath $childPath)" apply -auto-approve
```

- Ensure Gitea related OIDC client config is ready  
[TerraformWorkShop/Vault/Identity/OIDC](../../../../TerraformWorkShop/Vault/Identity/OIDC/terraform.tfvars)
```powershell
$repoDir=git rev-parse --show-toplevel
$childPath="TerraformWorkShop/Vault/Identity/OIDC/"
terraform -chdir="$(Join-Path -Path $repoDir -ChildPath $childPath)" apply -auto-approve
```

#### Deploy gitea nomad job
```powershell
$repoDir=git rev-parse --show-toplevel
$childPath="TerraformWorkShop/Nomad/Jobs/gitea/"
Set-Location -Path (Join-Path -Path $repoDir -ChildPath $childPath)
sudo pwsh.exe -c "[System.Environment]::SetEnvironmentVariable('CONSUL_HTTP_TOKEN',`"$env:CONSUL_HTTP_TOKEN`"); terraform -chdir=`"$(Join-Path -Path $repoDir -ChildPath $childPath)`" init -upgrade"; 
terraform -chdir="$(Join-Path -Path $repoDir -ChildPath $childPath)" apply -auto-approve
```

To cleanup gitea juicefs volume:
```powershell
# delete juicefs volume meta data in etcd
ssh Day1-FCOS
podman exec etcd-server etcdctl --insecure-skip-tls-verify --endpoints=https://localhost:2379 --user=root:P@ssw0rd del /juicefs/gitea-data/ --prefix=true

# delete juicefs volume chunk data in dufs
$credential="admin:admin"
curl.exe -X DELETE -k https://dufs.day1.sololab/webdav/csi-gitea-data/ --user $credential

# or
juicefs destroy etcd://juicefs:juicefs@etcd-0.day1.sololab:2379/juicefs/gitea-data/_
```