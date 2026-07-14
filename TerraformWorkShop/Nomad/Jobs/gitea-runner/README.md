### Requirements

#### Workload
- Ensure container image `gitea/runner` had synced to image registry  
[LocalWorkShop/Sync-OCIImage/Day5.jsonc](../../../../LocalWorkShop/Sync-OCIImage/Day5.jsonc)
```powershell
$repoDir=git rev-parse --show-toplevel
$childPath="LocalWorkShop/Sync-OCIImage"
Set-Location -Path (Join-Path -Path $repoDir -ChildPath $childPath)
$proxy="127.0.0.1:7890"; $env:HTTP_PROXY=$proxy; $env:HTTPS_PROXY=$proxy; $env:NO_PROXY="sololab,consul"
.\Sync-OCIImage.ps1 -PrivateRegistry "zot.day1.sololab" -SyncProfile "Day4.jsonc" # -Upload $false
# .\Sync-OCIImage.ps1 -PrivateRegistry "zot.day1.sololab" -SyncProfile "Day4.jsonc" -LocalStore "D:/Users/Public/Downloads/containers" -Upload $false
```

#### Security
- Ensure  nomad default workload identity has permission to access vault kvv2 backend `kvv2_gitea`  
[TerraformWorkShop/Vault/policy/terraform.tfvars](../../../../TerraformWorkShop/Vault/policy/terraform.tfvars)
```powershell
$repoDir=git rev-parse --show-toplevel
$childPath="TerraformWorkShop/Vault/policy"
terraform -chdir="$(Join-Path -Path $repoDir -ChildPath $childPath)" apply -auto-approve
```

#### Prepare gitea-runner token
```powershell
$credential = Get-Credential -Message "credential to login vault"
$env:VAULT_ADDR = "https://vault.day1.sololab"
vault login -no-print -method=ldap username=$($credential.UserName) password=$($credential.GetNetworkCredential().Password)

$adminUserName=$(vault kv get -format=json -mount=kvv2_others app-gitea | jq.exe .data.data.admin_username).Replace('"', '')
$adminPassword=$(vault kv get -format=json -mount=kvv2_others app-gitea | jq.exe .data.data.admin_password).Replace('"', '')
$giteaURI = "https://gitea.day4.sololab/api/v1/admin/actions/runners/registration-token"

$instanceRunnerToken = $(curl.exe -k -s `
    --request POST `
    -u "$($adminUserName):$($adminPassword)" `
    -H "Content-Type: application/json" `
    $giteaURI | jq.exe .token).Replace('"', '')

# store token in vault
$secretList=$(vault kv list -mount=kvv2_gitea -format=json | jq.exe . | convertfrom-json)
if (-not ($secretList -contains "token-instance_runner")) {
    vault kv put -mount=kvv2_gitea token-instance_runner token=$instanceRunnerToken
} else {
    vault kv patch -mount=kvv2_gitea token-instance_runner token=$instanceRunnerToken
}
```

#### Deploy gitea-runner nomad job
```powershell
$credential = Get-Credential -Message "credential to login vault"
$env:VAULT_ADDR = "https://vault.day1.sololab"
vault login -no-print -method=ldap username=$($credential.UserName) password=$($credential.GetNetworkCredential().Password)
$env:CONSUL_HTTP_TOKEN = $(vault kv get -format=json -mount=kvv2_consul token-tf_backend | jq.exe .data.data.token).Replace('"', '')
$env:NOMAD_TOKEN = $(vault kv get -format=json -mount=kvv2_nomad token-management | jq.exe .data.data.token).Replace('"', '')

$repoDir=git rev-parse --show-toplevel
$childPath="TerraformWorkShop/Nomad/Jobs/gitea-runner/"
Set-Location -Path (Join-Path -Path $repoDir -ChildPath $childPath)
sudo pwsh.exe -c "[System.Environment]::SetEnvironmentVariable('CONSUL_HTTP_TOKEN',`"$env:CONSUL_HTTP_TOKEN`"); terraform -chdir=`"$(Join-Path -Path $repoDir -ChildPath $childPath)`" init -upgrade"; 
terraform -chdir="$(Join-Path -Path $repoDir -ChildPath $childPath)" apply -auto-approve
```
