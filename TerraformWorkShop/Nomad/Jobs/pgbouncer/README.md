### Deploy pgbouncer to Nomad
```powershell
$credential = Get-Credential -Message "credential to login vault"

$vaultBaseUri = New-Object System.Uri("https://vault.day1.sololab/")
$vaultLoginEndpoint = "/v1/auth/ldap/login/$($credential.UserName)"
$vaultLoginUri = New-Object System.Uri($vaultBaseUri, "/v1/auth/ldap/login/$($credential.UserName)")
$vaultLoginUri.AbsoluteUri
$vaultToken = $(curl.exe -k -s --request POST `
    --data "{`"password`": `"$($credential.GetNetworkCredential().Password)`"}" `
    $vaultLoginUri | jq.exe .auth.client_token).Replace('"', '')
# get nomad token from kvv2 secret backend
$vaultSecretUri = New-Object System.Uri($vaultBaseUri, "/v1/kvv2_nomad/data/token-management")
$env:NOMAD_TOKEN = $(curl.exe -k -s -X GET `
    -H "X-Vault-Token: $vaultToken" `
    $vaultSecretUri.AbsoluteUri | jq.exe .data.data.token ).Replace('"', '')
$vaultSecretUri = New-Object System.Uri($vaultBaseUri, "/v1/kvv2_consul/data/token-tf_backend")
$env:CONSUL_HTTP_TOKEN = $(curl.exe -k -s -X GET `
    -H "X-Vault-Token: $vaultToken" `
    $vaultSecretUri.AbsoluteUri | jq.exe .data.data.token ).Replace('"', '')


$repoDir=git rev-parse --show-toplevel
$childPath="TerraformWorkShop/Nomad/Jobs/pgbouncer/"
Set-Location -Path (Join-Path -Path $repoDir -ChildPath $childPath)
sudo pwsh.exe -c "[System.Environment]::SetEnvironmentVariable('CONSUL_HTTP_TOKEN',`"$env:CONSUL_HTTP_TOKEN`"); terraform init -upgrade";
terraform apply --auto-approve
```