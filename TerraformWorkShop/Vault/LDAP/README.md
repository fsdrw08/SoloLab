```powershell
terraform init
terraform state rm $(terraform state list)
terraform plan
terraform apply -auto-approve
```

consider add MFA login enforcement
ref: https://developer.hashicorp.com/vault/tutorials/auth-methods/active-directory-mfa-login-totp
https://github.com/ausfestivus/terraform-prototypes/blob/281ae231d05aea0454411fb1b2412bfd75a738e2/terraform-vault-mfa-totp-userpass/prototype.tf#L33