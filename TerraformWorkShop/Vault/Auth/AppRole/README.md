```log
Error generating AppRole SecretID
│ 
│   with ephemeral.vault_approle_auth_backend_role_secret_id.secret_id["jenkins-secret-reader"],
│   on main.tf line 31, in ephemeral "vault_approle_auth_backend_role_secret_id" "secret_id":
│   31: ephemeral "vault_approle_auth_backend_role_secret_id" "secret_id" {
│ 
│ Could not generate SecretID at path auth/approle/role/jenkins-secret-reader/secret-id: Error making API request.
│ 
│ URL: PUT https://vault.day0.sololab/v1/auth/approle/role/jenkins-secret-reader/secret-id
│ Code: 404. Errors:
│ 
│ * role "jenkins-secret-reader" does not exist
```
```powershell
terraform apply -target="vault_approle_auth_backend_role.role[`"jenkins-secret-reader`"]"
```