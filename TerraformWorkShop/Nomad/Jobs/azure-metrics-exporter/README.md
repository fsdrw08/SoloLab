```powershell
$repoDir=git rev-parse --show-toplevel
$childPath="TerraformWorkShop/Nomad/Jobs/azure-metrics-exporter/"
Set-Location -Path (Join-Path -Path $repoDir -ChildPath $childPath)

$credential = Get-Credential -Message "credential to login vault"

$vaultBaseUri = New-Object System.Uri("https://vault.day0.sololab/")
$vaultLoginEndpoint = "/v1/auth/ldap/login/$($credential.UserName)"
$vaultLoginUri = New-Object System.Uri($vaultBaseUri, "/v1/auth/ldap/login/$($credential.UserName)")
$vaultLoginUri.AbsoluteUri
$vaultToken = $(curl.exe -k -s --request POST `
    --data "{`"password`": `"$($credential.GetNetworkCredential().Password)`"}" `
    $vaultLoginUri | jq.exe .auth.client_token).Replace('"', '')
# get consul kv token from kvv2 secret backend
$vaultConsulSecretUri = New-Object System.Uri($vaultBaseUri, "/v1/kvv2_consul/data/token-tf_backend")
$env:CONSUL_HTTP_TOKEN = $(curl.exe -k -s -X GET `
    -H "X-Vault-Token: $vaultToken" `
    $vaultConsulSecretUri.AbsoluteUri | jq.exe .data.data.token ).Replace('"', '')

$vaultNomadSecretUri = New-Object System.Uri($vaultBaseUri, "/v1/kvv2_nomad/data/token-management")
$env:NOMAD_TOKEN = $(curl.exe -k -s -X GET `
    -H "X-Vault-Token: $vaultToken" `
    $vaultNomadSecretUri.AbsoluteUri | jq.exe .data.data.token ).Replace('"', '')

# sudo pwsh.exe -c "[System.Environment]::SetEnvironmentVariable('CONSUL_HTTP_TOKEN',`"$env:CONSUL_HTTP_TOKEN`"); terraform init";
# terraform apply
```