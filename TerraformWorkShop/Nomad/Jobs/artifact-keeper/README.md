### Requirements
#### Network
- Ensure external DNS record for `artifact-keeper.day4.sololab` is ready  
[TerraformWorkShop/PowerDNS/zones](../../../../TerraformWorkShop/PowerDNS/zones/terraform.tfvars)
```powershell
$repoDir=git rev-parse --show-toplevel
$childPath="TerraformWorkShop/PowerDNS/zones/"
terraform -chdir="$(Join-Path -Path $repoDir -ChildPath $childPath)" apply -auto-approve
```

- Ensure internal DNS record for `artifact-keeper.day4.sololab` is ready 
[TerraformWorkShop/etcd/skydns](../../../../TerraformWorkShop/etcd/skydns/terraform.tfvars)
```powershell
$repoDir=git rev-parse --show-toplevel
$childPath="TerraformWorkShop/etcd/skydns/"
terraform -chdir="$(Join-Path -Path $repoDir -ChildPath $childPath)" apply -auto-approve
```

#### Workload
- Ensure container image `artifact-keeper/artifact-keeper-backend` had synced to image registry  
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
- Ensure external L4 loadbalancer for `artifact-keeper.day4.sololab` is ready  
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

#### Security
- Ensure artifact-keeper postgresql credential `pgsql_admin_password`, `pgsql_user_name`, `pgsql_user_password` is in vault is ready
[TerraformWorkShop/Vault/Secrets/Others/terraform.tfvars](../../../../TerraformWorkShop/Vault/Secrets/Others/terraform.tfvars)
```powershell
$credential = Get-Credential -Message "credential to login vault"
$env:VAULT_ADDR = "https://vault.day1.sololab"
vault login -no-print -method=ldap username=$($credential.UserName) password=$($credential.GetNetworkCredential().Password)

$repoDir=git rev-parse --show-toplevel
$childPath="TerraformWorkShop/Vault/Secrets/Others/"
terraform -chdir="$(Join-Path -Path $repoDir -ChildPath $childPath)" apply -auto-approve
```

- Ensure artifact-keeper related LDAP entities is ready  
[TerraformWorkShop/ldap/lldap](../../../../TerraformWorkShop/ldap/lldap/terraform.tfvars)
```powershell
$repoDir=git rev-parse --show-toplevel
$childPath="TerraformWorkShop/ldap/lldap/"
terraform -chdir="$(Join-Path -Path $repoDir -ChildPath $childPath)" apply -auto-approve
```

- Ensure artifact-keeper related LDAP group entity in LDAP server had synced to OIDC server  
[TerraformWorkShop/Vault/Auth/LDAP](../../../../TerraformWorkShop/Vault/Auth/LDAP/)
```powershell
$repoDir=git rev-parse --show-toplevel
$childPath="TerraformWorkShop/Vault/Auth/LDAP/"
terraform -chdir="$(Join-Path -Path $repoDir -ChildPath $childPath)" apply -auto-approve
```

- Ensure artifact-keeper related OIDC client config is ready  
[TerraformWorkShop/Vault/Identity/OIDC](../../../../TerraformWorkShop/Vault/Identity/OIDC/terraform.tfvars)
```powershell
$repoDir=git rev-parse --show-toplevel
$childPath="TerraformWorkShop/Vault/Identity/OIDC/"
terraform -chdir="$(Join-Path -Path $repoDir -ChildPath $childPath)" apply -auto-approve
```

#### Deploy artifact-keeper nomad job
```powershell
$credential = Get-Credential -Message "credential to login vault"
$env:VAULT_ADDR = "https://vault.day1.sololab"
vault login -no-print -method=ldap username=$($credential.UserName) password=$($credential.GetNetworkCredential().Password)
$env:CONSUL_HTTP_TOKEN = $(vault kv get -format=json -mount=kvv2_consul token-role-tf_backend | jq.exe .data.data.token).Replace('"', '')
$env:NOMAD_TOKEN = $(vault kv get -format=json -mount=kvv2_nomad token-management | jq.exe .data.data.token).Replace('"', '')

$repoDir=git rev-parse --show-toplevel
$childPath="TerraformWorkShop/Nomad/Jobs/artifact-keeper/"
Set-Location -Path (Join-Path -Path $repoDir -ChildPath $childPath)
sudo pwsh.exe -c "[System.Environment]::SetEnvironmentVariable('CONSUL_HTTP_TOKEN',`"$env:CONSUL_HTTP_TOKEN`"); terraform -chdir=`"$(Join-Path -Path $repoDir -ChildPath $childPath)`" init -upgrade"; 
terraform -chdir="$(Join-Path -Path $repoDir -ChildPath $childPath)" apply -auto-approve
```
