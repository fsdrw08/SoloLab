a lab to build all VMs in one (windows 10+) host
## the procedure
1. Enable hyper-v first, you can refer this [code snippet](https://github.com/fsdrw08/WinOS-Deploy-As-Code/blob/main/oobeSystem/firstLogonScript.ps1#L175-L185) to enable hyper-v
2. Run [.\LocalWorkShop\New-VMSwitch.ps1](LocalWorkShop/New-VMSwitch.ps1) to create a Hyper-V internal facing virtual switch, then run [.\LocalWorkShop/Set-NetIPInterface.ps1](LocalWorkShop/Set-NetIPInterface.ps1) to config MAC for the NIC connected to this switch
3. Install packer, vagrant, kubectl, helm
   by scoop
   ```
   scoop install packer vagrant kubectl helm
   ```
4. Build vagrant box (the hyper-v vm template) from packer
5. Up the vagrant box
6. Config k3s cluster

### to add git sub module
```powershell
cd $(git rev-parse --show-toplevel)
$url="https://github.com/freeipa/ansible-freeipa.git"
$submoduleDir="AnsibleWorkShop/runner/project/roles/ansible-freeipa"

# ansible-role-k3s
$url="https://github.com/PyratLabs/ansible-role-k3s.git"
$branch="v3_release"
$submoduleDir="AnsibleWorkShop/runner/project/roles/ansible-role-k3s"
git submodule add --force -b $branch $url $submoduleDir
```