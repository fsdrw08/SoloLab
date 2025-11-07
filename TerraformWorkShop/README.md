ref: 
- [解决Terraform初始化慢~配置本地离线源](https://cloud.tencent.com/developer/article/1987762)
- [plugin-dir](https://developer.hashicorp.com/terraform/cli/commands/init#plugin-dir-path)
- [custom terrafrom configurations in file](https://developer.hashicorp.com/terraform/cli/config/config-file#locations)

This guile is used to download all providers this project need, set up terraform config, let terraform load providers from local instead of internet

### Setup terraform.rc
Should run by powershell 7+, in current dir, run:
```powershell
. .\Set-TFCLIConfigFile.ps1
```

### Download terraform providers
In current dir, run:
```powershell
# config http proxy if require
$proxy="127.0.0.1:7890"
$env:HTTP_PROXY=$proxy;$env:HTTPS_PROXY=$proxy;$env:NO_PROXY="sololab"
# setup target download folder
$publicDir=$env:PUBLIC
# $publicDir="D:\Users\Public\"
$repoDir = git rev-parse --show-toplevel
$currentDir = Join-Path -Path $repoDir -ChildPath "TerraformWorkShop"
Set-Location $currentDir
terraform providers mirror (Join-Path -Path $publicDir -ChildPath "Downloads\terraform.d\mirror")
$env:HTTP_PROXY=$null;$env:HTTPS_PROXY=$null
```

### When run terraform in target dir
Ensure have permission to create symlink in windows
ref: https://github.com/hashicorp/terraform/blob/v1.12.2/internal/providercache/package_install.go#L216

run terraform with sudo (win11 23h2+) to create symlink
```powershell
sudo terraform init
# or 
terraform init --plugin-dir (Join-Path -Path $projectPath -ChildPath ".terraform.d/mirror/registry.terraform.io/")
```

or download from https://releases.hashicorp.com/


