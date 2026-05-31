tf resources in this dir are used to manage consul acl policy rule, acl role, acl token, and store acl token to vault kvv2 secret backend,  
and also config Vault as consul CA provider, use vault app role to let consul auto renew vault token, and use this token to apply, renew cert for consul internal communication.

ACL resource relationship mapping:
any policies -> one role -> one token -> vault kvv2 secret backend (optional)


### Requirements:
- Ensure consul connect related app role ACL policy `consul-ca` in Vault is ready  
[TerraformWorkShop/Vault/policy/terraform.tfvars](../../../TerraformWorkShop/Vault/policy/terraform.tfvars)
```powershell
$repoDir=git rev-parse --show-toplevel
$childPath="TerraformWorkShop/Vault/policy/"
terraform apply -chdir="$(Join-Path -Path $repoDir -ChildPath $childPath)"  -auto-approve
```
- Ensure consul connect related app role `consul-connect-pki` (used to apply and renew certs) in Vault is ready  
[TerraformWorkShop/Vault/Auth/AppRole/terraform.tfvars](../../../TerraformWorkShop/Vault/Auth/AppRole/terraform.tfvars)
```powershell
$repoDir=git rev-parse --show-toplevel
$childPath="TerraformWorkShop/Vault/Auth/AppRole/"
terraform apply -chdir="$(Join-Path -Path $repoDir -ChildPath $childPath)"  -auto-approve
```
- Ensure consul intermediate CA mount path `pki_consul_int` is ready in Vault  
[TerraformWorkShop/Vault/Secrets/PKI/Int_CA/terraform.tfvars](../../../TerraformWorkShop/Vault/Secrets/PKI/Int_CA/terraform.tfvars)
```powershell
$repoDir=git rev-parse --show-toplevel
$childPath="TerraformWorkShop/Vault/Secrets/PKI/Int_CA/"
terraform apply -chdir="$(Join-Path -Path $repoDir -ChildPath $childPath)"  -auto-approve
```