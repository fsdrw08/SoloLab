1. run presync script to prepare the helm chart related info (e.g. CA key pair, RBAC user name)
```
sh Start-PreConfig.sh
```

2. Run helmfile
```
helmfile -f /var/vagrant/HelmWorkShop/helmfile/helmfile.yaml sync
```
or 
```
sh /var/vagrant/HelmWorkShop/helmfile/Start-PreConfig.sh && helmfile -f /var/vagrant/HelmWorkShop/helmfile/helmfile.yaml apply --skip-deps
```
to run helmfile -f ... apply, need to install helm diff first
```
helm plugin install https://github.com/databus23/helm-diff
# or
helm plugin install https://gitee.com/baijunyao/helm-diff
```