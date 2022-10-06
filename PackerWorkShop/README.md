1. Download related ISO to `$env:USERPROFILE\Downloads\ISO\`  
   VYOS: https://github.com/9l/vyos-build-action/releases ~~https://vyos.net/get/snapshots/~~ (already disapeared)  
   Alpine Linux: https://www.alpinelinux.org/downloads/
2. Run script [.\ISO\New-HardLink.bat](ISO/New-HardLink.bat) to create ISO hardlink from `$env:USERPROFILE\Downloads\ISO\` to this folder
3. Install dos2unix, mkisofs
   by scoop
   ```
   scoop install dos2unix mkisofs
   ```
4. Creae vyos vagrant box by running [.\VyOS\hv_vyos130_vagrant.ps1](VyOS/hv_vyos130_vagrant.ps1)  
   or
   ```powershell
   cd (Join-Path (git rev-parse --show-toplevel) "\PackerWorkShop\VyOS\")
   . .\Invoke-PackerBuild.ps1 13x
   ```
   For the reasone that Vyos identify the nic by mac address, In oder fix the relationship between NIC and switch (e.g. eth0 for WAN, forever), we need to bind MAC address to the NIC (eth0 by default), if we dont bind the mac address to NIC, the vyos Hyper-V VM (vagrant) instance will have different MAC address each time (when run `vagrant up`), which means the WAN switch will connect to eth1 after the instance get created
   Thus this packer build will create a vyos vm, hard code eth0's mac address, and connect eth0 to default switch. 
5. Set up the vyos vagrant box instance