backup xfs filesystem:
```shell
cd /var/home/core
sudo xfsdump -L podmgr -f podmgr.xfsdump /var/home/podmgr
```

restore:
```
cd /var/home/core
sudo xfsrestore -f podmgr_2.xfsdump /var/home/podmgr
```