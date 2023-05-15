in order to build vyos image in hyper-v (win11 22h2+) successfully, refer https://github.com/hashicorp/packer-plugin-hyperv/issues/65#issuecomment-1420237055 to clone [packer-plugin-hyperv](https://github.com/hashicorp/packer-plugin-hyperv) locally, and build the packer hyper-v plugin bin file, place the file in this folder, then run below command to build
```powershell
.\Invoke-PackerBuild.ps1 13x-cloudinit
```