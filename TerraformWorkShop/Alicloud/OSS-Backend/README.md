ref:
- https://help.aliyun.com/document_detail/145541.html#section-ikv-9za-fsj

## init OSS backend
1. config aliyun to let it generate profile:
```powershell
aliyun configure --profile cn_hk
Access Key Id []: ...
Access Key Secret []: ...
Default Region Id []: cn-hongkong
```

2. change the default subfix random code in variables.tf `bucket_name`
```s
variable "bucket_name" {
  description = "The name of the bucket"
  default     = "terraform-remote-backend-9c53" # 9c53 -> other code
}
```

3. run terraform to create oss and ots
```powershell
terraform init
terraform plan
terraform approve --auto-approve
```

## migrate tfstate from local to alicloud oss
1. after oss and ots created, this module will also output a bock of oss backend config code for the oss backend config, copy and paste it in provider.

2. run `terraform init` again, terraform will migrate `terraform.tfstate` to oss backend