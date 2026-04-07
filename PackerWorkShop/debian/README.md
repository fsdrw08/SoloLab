### Provision Debian 13 vm image
[PackerWorkShop/debian/](../../PackerWorkShop/debian/)
```powershell
$repoDir=git rev-parse --show-toplevel
$childPath="PackerWorkShop/debian/"
Set-Location -Path (Join-Path -Path $repoDir -ChildPath $childPath)
.\Invoke-PackerBuild.ps1 -OSVersion 13 -except "vagrant"
```