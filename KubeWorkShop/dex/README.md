### install dex
```shell
APP_DIR="dex"
mkdir -p $HOME/infra/$APP_DIR/data

podman kube play /var/vagrant/KubeWorkShop/dex/pod-dex.yaml \
    --configmap /var/vagrant/KubeWorkShop/dex/cm-dex.yaml
```
