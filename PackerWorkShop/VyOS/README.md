in order to build vyos image in hyper-v (win11 22h2+) successfully, refer https://github.com/hashicorp/packer-plugin-hyperv/issues/65#issuecomment-1420237055 to clone [packer-plugin-hyperv](https://github.com/hashicorp/packer-plugin-hyperv) locally, and build the packer hyper-v plugin bin file, place the file in this folder, then run below command to build
```powershell
# set up proxy if need, for packer plugin install
$proxy="127.0.0.1:7890"
$env:HTTP_PROXY=$proxy; $env:HTTPS_PROXY=$proxy
packer init .\plugins.pkr.hcl
# run packer build
.\Invoke-PackerBuild.ps1 14x-cloudinit
```