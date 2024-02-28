```powershell
terraform init
terraform state rm $(terraform state list)
terraform plan
terraform apply -auto-approve
```