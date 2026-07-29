[URL Validation and Private Network Access](https://help.sonatype.com/en/securing-nexus-repository-manager.html#url-validation-and-private-network-access)  
Sonatype Nexus Repository allows URL validation to reduce the risk of Server-Side Request Forgery (SSRF) when configuring outbound connections. This validation applies to proxy repository Remote Storage URLs and Amazon S3 blob store Endpoint URL values. When you save a configuration, Nexus Repository checks whether the specified URL resolves to a private network address, a localhost or loopback address, or a cloud instance metadata address. If validation is enabled and the URL resolves to a blocked address, the configuration cannot be saved.

### Config nexus blob store
```powershell
$credential = Get-Credential -Message "credential to login vault" -UserName "000"
$env:VAULT_ADDR = "https://vault.day1.sololab"
vault login -no-print -method=ldap username=$($credential.UserName) password=$($credential.GetNetworkCredential().Password)
$env:CONSUL_HTTP_TOKEN = $(vault kv get -format=json -mount=kvv2_consul token-role-tf_backend | jq.exe .data.data.token).Replace('"', '')


$repoDir=git rev-parse --show-toplevel
$childPath="TerraformWorkShop/Nexus/BlobStore/"
Set-Location -Path (Join-Path -Path $repoDir -ChildPath $childPath)
sudo pwsh.exe -c "[System.Environment]::SetEnvironmentVariable('CONSUL_HTTP_TOKEN',`"$env:CONSUL_HTTP_TOKEN`"); terraform init"; 
terraform apply -auto-approve
```