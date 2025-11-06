Before run script to sync the image, install skopeo first, download skopeo for windows from https://github.com/passcod/winskopeo/releases, then put it in C:\Windows\

### Sync container image to private registry
[LocalWorkShop/Sync-OCIImage/](./)
```powershell
$repoDir=git rev-parse --show-toplevel
$childPath="LocalWorkShop/Sync-OCIImage"
Set-Location -Path (Join-Path -Path $repoDir -ChildPath $childPath)
$proxy="127.0.0.1:7890"; $env:HTTP_PROXY=$proxy; $env:HTTPS_PROXY=$proxy; $env:NO_PROXY="sololab"
.\Sync-OCIImage.ps1 -SyncProfile "VyOS.jsonc"  -PrivateRegistry "zot.vyos.sololab.dev"
# .\Sync-OCIImage.ps1 -SyncProfile "VyOS.jsonc" -LocalStore "D:/Users/Public/Downloads/containers" -PrivateRegistry "zot.vyos.sololab.dev"
```