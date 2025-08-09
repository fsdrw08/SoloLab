### Prepare FCOS Hyper-V image for this project
1. Download FCOS Hyper-V image
[Download Fedora CoreOS](https://fedoraproject.org/coreos/download?stream=stable)

2. Create image dir
```powershell
$ImageDir="C:\ProgramData\Microsoft\Windows\Virtual Hard Disks\Images\fcos"
if (-not (Test-Path $ImageDir)) {
    New-Item -Path $ImageDir -ItemType "Directory"
}
```

3. Extra the vhd file to `C:\ProgramData\Microsoft\Windows\Virtual Hard Disks\Images\fcos`

4. Rename the vhd to `fedora-coreos-hyperv.x86_64.vhdx` in `C:\ProgramData\Microsoft\Windows\Virtual Hard Disks\Images\fcos`

### Prepare kvpctl tool
1. Download kvpctl.exe from https://github.com/containers/libhvee/releases

2. Extra exe file to C:\Windows

### Run terraform
```powershell
sudo terraform init
terraform apply --auto-approve
```
For the reason the the ignition process can only run before VM first boot up, 
we have to turn on the VM manually.

### Others: Backup and restore xfs filesystem:
backup
```shell
cd /var/home/core
sudo xfsdump -L podmgr -f podmgr.xfsdump /var/home/podmgr
```

restore:
```shell
cd /var/home/core
sudo xfsrestore -f podmgr_2.xfsdump /var/home/podmgr
```