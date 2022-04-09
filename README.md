a lab to build all VMs in one (windows 10+) host
## the procedure
1. Enable hyper-v first, you can refer this [code snippet](https://github.com/fsdrw08/WinOS-Deploy-As-Code/blob/main/oobeSystem/firstLogonScript.ps1#L175-L185) to enable hyper-v
2. Create a Hyper-V internal virtual switch, and config MAC for the NIC connected to this switch
3. Install packer, vagrant, kubectl, helm
   by scoop
   ```
   scoop install packer vagrant kubectl helm
   ```
4. Build vagrant box (the hyper-v vm template) from packer
5. Up the vagrant box
6. Config k3s cluster