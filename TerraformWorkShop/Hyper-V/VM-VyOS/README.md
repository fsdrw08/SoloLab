setup vyos vm instance by apply hyper-v related resources (cloud-init iso, vhd, vm)
update `terraform.tfvars` first
```powershell
terraform init
terraform plan
terraform apply -auto-approve
# to import (update) existing resource
terraform import hyperv_machine_instance.VyOS-LTS VyOS-LTS
# to destroy
terraform destroy -auto-approve
```