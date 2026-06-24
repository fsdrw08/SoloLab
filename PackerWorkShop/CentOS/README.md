### Download CentOS image
https://mirrors.tuna.tsinghua.edu.cn/centos-stream/10-stream/BaseOS/x86_64/iso/

### Install packer plugins
```powershell
$repoDir=git rev-parse --show-toplevel
$childPath="PackerWorkShop/CentOS/"
Set-Location -Path (Join-Path -Path $repoDir -ChildPath $childPath)
# set up proxy if need, for packer plugin install
$proxy="127.0.0.1:7890"
$env:HTTP_PROXY=$proxy; $env:HTTPS_PROXY=$proxy
packer init .\plugins.pkr.hcl
```

### run packer build
```powershell
. .\Invoke-PackerBuild.ps1 -OSVersion 'stream-10' -except "vagrant"
```