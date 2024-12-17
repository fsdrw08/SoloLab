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
$proxy="192.168.255.1:7890"
$env:HTTP_PROXY=$proxy;$env:HTTPS_PROXY=$proxy
terraform providers mirror (Join-Path -Path $env:PUBLIC -ChildPath "Downloads\terraform.d\mirror")
$env:HTTP_PROXY=$null;$env:HTTPS_PROXY=$null
```

3. Ensure have permission to create symlink in windows
ref: https://github.com/hashicorp/terraform/blob/1714729f8730d2184b9c529768c56f37e3913ec0/internal/providercache/package_install.go#L229

4. run terraform init
```powershell
terraform init --plugin-dir (Join-Path -Path $projectPath -ChildPath ".terraform.d/mirror/registry.terraform.io/")
# or 
sudo terraform init
```

or download from https://releases.hashicorp.com/


