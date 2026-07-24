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
$credential = Get-Credential -Message "credential to login vault"

$env:VAULT_ADDR = "https://vault.day1.sololab"
vault login -no-print -method=ldap username=$($credential.UserName) password=$($credential.GetNetworkCredential().Password)
$env:CONSUL_HTTP_TOKEN = $(vault kv get -format=json -mount=kvv2_consul token-role-tf_backend | jq.exe .data.data.token).Replace('"', '')

$repoDir=git rev-parse --show-toplevel
$childPath="TerraformWorkShop/Hyper-V/VM-Day4-FCOS"
Set-Location -Path (Join-Path -Path $repoDir -ChildPath $childPath)
sudo pwsh.exe -c "[System.Environment]::SetEnvironmentVariable('CONSUL_HTTP_TOKEN',`"$env:CONSUL_HTTP_TOKEN`"); terraform -chdir=`"$(Join-Path -Path $repoDir -ChildPath $childPath)`" init -upgrade"; 
terraform -chdir="$(Join-Path -Path $repoDir -ChildPath $childPath)" apply -auto-approve
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

### Upgrade system image from private container registry:
1. Disable zincati service
2. Push the latest os image to private registry
3. Ensure vm's system image had rebased to the private registry (by this service, or the `rpm-ostree rebase` command)
4. Run `sudo rpm-ostree upgrade && sudo systemctl reboot`
ref: https://discussion.fedoraproject.org/t/zincati-cannot-to-update-to-new-image/105920/17
5. Run `sudo rpm-ostree cleanup -r` to clean up the old ostree deployments and free up space on Fedora CoreOS

### Upgrade consul and nomad binaries in Day3-FCOS VM:
```shell
sudo bash -c "consul_download_url=http://dufs.day1.sololab/public/binaries/consul_2.0.2_linux_amd64.zip custom_bin_dir=/opt/bin /opt/bin/consul_install.sh"
sudo bash -c "nomad_download_url=http://dufs.day1.sololab/public/binaries/nomad_2.0.3_linux_amd64.zip custom_bin_dir=/opt/bin /opt/bin/nomad_install.sh"
```