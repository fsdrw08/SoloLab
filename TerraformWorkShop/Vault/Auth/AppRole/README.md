### Config AppRole auth backend (login) in Vault
[TerraformWorkShop/Vault/Auth/AppRole](../../TerraformWorkShop/Vault/Auth/AppRole/)
```powershell
$credential = Get-Credential -Message "credential to login vault" -UserName "000"
$env:VAULT_ADDR = "https://vault.day1.sololab"
vault login -no-print -method=ldap username=$($credential.UserName) password=$($credential.GetNetworkCredential().Password)

$repoDir=git rev-parse --show-toplevel
$childPath="TerraformWorkShop/Vault/Auth/AppRole"
Set-Location -Path (Join-Path -Path $repoDir -ChildPath $childPath)
sudo pwsh.exe -c "terraform init -upgrade";
terraform apply --auto-approve
```

in case of below error:
```log
Error generating AppRole SecretID
│ 
│   with ephemeral.vault_approle_auth_backend_role_secret_id.secret_id["jenkins-secret-reader"],
│   on main.tf line 31, in ephemeral "vault_approle_auth_backend_role_secret_id" "secret_id":
│   31: ephemeral "vault_approle_auth_backend_role_secret_id" "secret_id" {
│ 
│ Could not generate SecretID at path auth/approle/role/jenkins-secret-reader/secret-id: Error making API request.
│ 
│ URL: PUT https://vault.day1.sololab/v1/auth/approle/role/jenkins-secret-reader/secret-id
│ Code: 404. Errors:
│ 
│ * role "jenkins-secret-reader" does not exist
```
solution:
```powershell
$roleName=Read-Host "role name"
terraform apply -target="vault_approle_auth_backend_role.role[`"$roleName`"]"
terraform apply
```