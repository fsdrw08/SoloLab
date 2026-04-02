ref:
meta-data
https://gist.github.com/wipash/81064e811c08191428002d7fe5da5ca7
https://cloudinit.readthedocs.io/en/latest/reference/datasources/nocloud.html#example-meta-data
https://cloudinit.readthedocs.io/en/latest/reference/network-config.html#network-configuration-sources

https://cloudinit.readthedocs.io/en/latest/reference/datasources/nocloud.html#example-meta-data

user-data
https://cloudinit.readthedocs.io/en/latest/reference/examples.html#yaml-examples

nocloud
https://cloudinit.readthedocs.io/en/latest/reference/datasources/nocloud.html#example-meta-data

run `New-CIDATA.ps1` to generate the ISO

```powershell
. "C:\Program Files\qemu\qemu-img.exe" convert ` "C:\Users\WindomWu\Downloads\vhd\debian-10-genericcloud-amd64.qcow2" -O vhdx -o subformat=dynamic ` "C:\Users\WindomWu\Downloads\vhd\debian-10-genericcloud-amd64.vhdx"
```