1. run [Set-TFCLIConfigFile.ps1](Set-TFCLIConfigFile.ps1) to setup terraform.rc

2. go to terraform resources related folder, run below command in 
```powershell
$projectPath = git rev-parse --show-toplevel
terraform providers mirror (Join-Path -Path $projectPath -ChildPath "TerraformWorkShop\terraform.d\plugins")
```

or download from https://releases.hashicorp.com/