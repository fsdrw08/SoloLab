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
Default Region Id []: ap-southeast-1
```

for multi region config:
ref: [cen_proxy_sample/terraform.tf](https://github.com/mosuke5/terraform_examples_for_alibabacloud/blob/4f36f46dd3b5329a6e154f1c118308814641464e/cen_proxy_sample/terraform.tf)

```powershell
aliyun configure --profile ap-sg
Access Key Id []: ...
Access Key Secret []: ...
Default Region Id []: ap-southeast-1

aliyun configure --profile cn-gz
Access Key Id []: ...
Access Key Secret []: ...
Default Region Id []: cn-guangzhou
```

3. put below key word in backend oss config
ref: https://developer.hashicorp.com/terraform/language/settings/backends/oss
```hcl
terraform {
  backend "oss" {
      profile             = "<the profile name (ap-sg in this case)>"
      ...
  }    
}
```

4. run teraform command
```powershell
terraform init -migrate-state
terraform init
```