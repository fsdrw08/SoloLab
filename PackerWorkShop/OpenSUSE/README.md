- check repo
```
zypper lr -U
```

- disable default repo
```
zypper mr -d openSUSE-MicroOS-5.2-OSS
```
- add tuna repo
```shell
sudo zypper ar -cfg 'https://mirrors.tuna.tsinghua.edu.cn/opensuse/distribution/leap-micro/5.2/product/repo/Leap-Micro-5.2-x86_64-Media/' 'Leap Micro Main Repository tuna'
zypper mr -e 'Leap Micro Main Repository tuna'
sudo zypper ar -cfg 'https://mirrors.tuna.tsinghua.edu.cn/opensuse/tumbleweed/repo/oss/' tuna-Tumbleweed-oss
sudo zypper ar -cfg 'https://mirrors.tuna.tsinghua.edu.cn/opensuse/update/leap/x86_64/' openSUSE-stable-tuna
https://mirrors.tuna.tsinghua.edu.cn/opensuse/update/openSUSE-stable/x86_64/
```

- disable repo
```shell
sudo zypper mr -d 'Update repository of openSUSE Backports'
```
- remove package
  ```shell
  sudo transactional-update --non-interactive -c pkg remove python3
  ```