ref: [解决Terraform初始化慢~配置本地离线源](https://cloud.tencent.com/developer/article/1987762)

1. run [Set-TFCLIConfigFile.ps1](Set-TFCLIConfigFile.ps1) to setup terraform.rc
```powershell
$projectPath = git rev-parse --show-toplevel
. $(Join-Path -Path $projectPath -ChildPath "TerraformWorkShop\Set-TFCLIConfigFile.ps1")
```

2. go to terraform resources related folder, run below command
```powershell
$projectPath = git rev-parse --show-toplevel
# terraform providers mirror (Join-Path -Path $projectPath -ChildPath "TerraformWorkShop\terraform.d\mirror")
terraform providers mirror (Join-Path -Path $env:PUBLIC -ChildPath "Downloads\terraform.d\mirror")
```

1. run terraform init
```powershell
terraform init --plugin-dir (Join-Path -Path $projectPath -ChildPath ".terraform.d/mirror/registry.terraform.io/")
```

or download from https://releases.hashicorp.com/


