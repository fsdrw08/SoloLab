1. fill out the k3s ca cert and key in helmfile for cert-manager ca issuer
```shell
# switch to root first
sudo su
# prase the key info
sed -i -e "/tls.crt:/s/$/$(cat /var/lib/rancher/k3s/server/tls/server-ca.crt | base64 -w0)/" \
-e "/tls.key:/s/$/$(cat /var/lib/rancher/k3s/server/tls/server-ca.key | base64 -w0)/" \
/var/vagrant/HelmWorkShop/cert-manager/extra-raw-values.yaml
# have a check
cat /var/vagrant/HelmWorkShop/cert-manager/extra-raw-values.yaml
```

then install
```
helmfile -f /var/vagrant/HelmWorkShop/helmfile/sololab.yaml sync
```