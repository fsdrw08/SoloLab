### not ready for vyos, dont use this

ref: https://github.com/sskaje/ubnt-clash/blob/master/README.zh.md
1. copy deb to vyos, run in local machine
```powershell
$debPath = "$env:USERPROFILE\OneDrive\Software\Network\ubntclash-linux\*"
scp $debPath vyos:/tmp/
```
2. install deb in vyos
run on vyos
```shell
sudo su
dpkg -i  /tmp/ubnt-clash_0.4.5_all.deb
```

3. config ubnt-clash
run on vyos, suggest type command in console mode, because in order to preform the question mark, need type ctrl + v then "?" in console
```shell
configure
set interfaces clash utun config-url https://........
commit
save
```

4. install clash binary
```shell
# install yq first
sudo mv /tmp/yq_linux_amd64 /usr/bin/yq
chmod +x /usr/bin/yq
# install clash
sudo su
USE_PROXY=1 /usr/bin/sh /tmp/clashctl.sh install

# install clash binary
bash /tmp/
```

5. config clash
```
set protocols static table 10 interface-route 0.0.0.0/0 next-hop-interface utun

set firewall group address-group SRC_CLASH address 192.168.255.100-192.168.255.250
set firewall modify MCLASH rule 101 action modify
set firewall modify MCLASH rule 101 modify table 10
set firewall modify MCLASH rule 101 source group address-group SRC_CLASH

set interfaces ethernet eth1 firewall in modify MCLASH

```