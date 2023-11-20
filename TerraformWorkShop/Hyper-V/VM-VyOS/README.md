## Deploy vyos on hyper-v by this terraform module
1. Prepare the VYOS vhd image, in this folder, run
```powershell
. ..\..\..\PackerWorkShop\VyOS\Invoke-PackerBuild.ps1 -VyOSVersion 13x-cloudinit
```
After success finish, the vhd image will stay in 
`C:\ProgramData\Microsoft\Windows\Virtual Hard Disks\Images\Virtual Hard Disks\packer-vyos134.vhdx`

2. Ensure hyper-v host's winrm had enabled, in this folder, run
```powershell
. ..\..\..\LocalWorkShop\Update-WinRMConfig\Update-WinRMConfig.bat
```

3. Prepare internal vswitch, see  [Switch-Internal](../Switch-Internal/)

4. Prepare data disk, see [Disk-VyOS-Data](../Disk-VyOS-Data/)

5. Run terraform in this folder
```powershell
terraform init
terraform apply --auto-approve
```

6. Prepare ssh config, copy ssh config to local
```powershell
$ssh = Join-Path -Path (git rev-parse --show-toplevel) -ChildPath "LocalWorkShop\.ssh"
Copy-Item -Path $ssh -Destination $env:USERPROFILE
```

6. ssh into vyos
```powershell
ssh vyos
```

## Post process
```shell
# config external disk
sudo su
bash /tmp/Set-ExternalDisk.sh

# add container (consul)
bash /tmp/Add-Container.sh
```