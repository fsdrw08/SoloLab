## to config alicloud oss provider

1. install aliyun cli
```powershell
winget install winget install Alibaba.AlibabaCloudCLI
```
then restart explorer, to let aliyun cli path take effect

2. config aliyun cli
```powershell
aliyun configure --profile default
Access Key Id []: ...
Access Key Secret []: ...
```

3. put below key word in backend oss config
ref: https://developer.hashicorp.com/terraform/language/settings/backends/oss
```hcl
terraform {
  backend "oss" {
      profile             = "default"
      ...
  }    
}
```

4. run teraform command
```powershell
terraform init -migrate-state
terraform init
```