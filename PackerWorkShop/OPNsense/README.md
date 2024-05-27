1. install:
login: `installer`  
password: `opnsense`

2. reboot, loin, 8 -> shell
ref: 
- https://www.bilibili.com/read/cv23127805
- https://github.com/yrzr/yrzr.github.io/blob/3ca657e2250a6841998f2d2b5dc2161b161d8f59/content/posts/opnsense-22-for-aarch64.en.md
```shell
# update repo url
vi /usr/local/etc/pkg/repos/OPNsense.conf
# change url to https://mirrors.pku.edu.cn/opnsense
```

3. install cloud-init
ref: https://unix.stackexchange.com/questions/672292/how-can-i-use-cloud-init-nocloud-with-opnsense-21
```shell
pkg install -y net/cloud-init
```

4. enable cloud-init
5. ref: 
- https://unix.stackexchange.com/questions/672292/how-can-i-use-cloud-init-nocloud-with-opnsense-21
- https://github.com/niki-on-github/k3s-infra-playground/blob/05048024a1f4bda16629097073834b9f363943af/packer/opnsense/opnsense.pkr.hcl#L11
```shell
vi /etc/rc.conf.d/cloud
# cloudinit_enable="YES"
```