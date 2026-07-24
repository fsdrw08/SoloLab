### Requirements
#### Users
- Ensure users had already been present in Gitea  
[TerraformWorkShop/Gitea/user](../user)
- Ensure users had already login to Gitea

### Create gitea organization
```powershell
$credential = Get-Credential -Message "credential to login vault"
$env:VAULT_ADDR = "https://vault.day1.sololab"
vault login -no-print -method=ldap username=$($credential.UserName) password=$($credential.GetNetworkCredential().Password)
$env:CONSUL_HTTP_TOKEN = $(vault kv get -format=json -mount=kvv2_consul token-role-tf_backend | jq.exe .data.data.token).Replace('"', '')

$repoDir=git rev-parse --show-toplevel
$childPath="TerraformWorkShop/Gitea/org/"
Set-Location -Path (Join-Path -Path $repoDir -ChildPath $childPath)
sudo pwsh.exe -c "[System.Environment]::SetEnvironmentVariable('CONSUL_HTTP_TOKEN',`"$env:CONSUL_HTTP_TOKEN`"); terraform -chdir=`"$(Join-Path -Path $repoDir -ChildPath $childPath)`" init -upgrade"; 
terraform -chdir="$(Join-Path -Path $repoDir -ChildPath $childPath)" apply -auto-approve
```