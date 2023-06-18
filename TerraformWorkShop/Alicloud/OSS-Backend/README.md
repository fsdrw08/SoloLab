ref:
- https://help.aliyun.com/document_detail/145541.html#section-ikv-9za-fsj

## init OSS backend
1. set env var for credential:
```powershell
$env:ALICLOUD_ACCESS_KEY="xxx"
$env:ALICLOUD_SECRET_KEY="xxx"
$env:ALICLOUD_REGION="ap-southeast-1"
```

2. run terraform to create oss and ots
```powershell
terraform init
terraform plan
terraform approve --auto-approve
```

## migrate tfstate from local to alicloud oss
1. after oss and ots created, this module will also generate a `terraform.tf.sample` file for the oss backend config, rename this file to `terraform.tf`

2. run `terraform init` again, terraform will migrate `terraform.tfstate` to oss backend