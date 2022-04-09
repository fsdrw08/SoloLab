1. Download related ISO to `$env:USERPROFILE\Downloads\ISO\`  
   VYOS: https://vyos.net/get/snapshots/  
   Alpine Linux: https://www.alpinelinux.org/downloads/
2. Run script [.\ISO\New-HardLink.bat](ISO/New-HardLink.bat) to create ISO hardlink from `$env:USERPROFILE\Downloads\ISO\` to this folder
3. Install dos2unix, mkisofs
   by scoop
   ```
   scoop install dos2unix mkisofs
   ```
4. Creae vyos vagrant box by running [.\VyOS\hv_vyos130_vagrant.ps1](VyOS/hv_vyos130_vagrant.ps1)
5. Set up the vyos vagrant box instance