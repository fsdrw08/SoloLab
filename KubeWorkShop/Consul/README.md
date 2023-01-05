### Deploy Consul
Deploy the container
```shell
mkdir -p $HOME/infra/consul/data

podman kube play /var/vagrant/KubeWorkShop/Consul/pod-consul_new.yaml \
    --configmap /var/vagrant/KubeWorkShop/Consul/cm-consul.yaml 

# to delete
podman kube down /var/vagrant/KubeWorkShop/Consul/pod-consul_new.yaml
```

Enable container start up when system start (gen the unit file and pass to home path systemd, also lingering current user)
```shell
mkdir -p $HOME/.config/systemd/user
# generate the systemd unit file
SERVICENAME="consul-consul"
echo $SERVICENAME
podman generate systemd --name $SERVICENAME > $HOME/.config/systemd/user/$SERVICENAME.service
# have a check
cat $HOME/.config/systemd/user/$SERVICENAME.service
systemctl --user enable $SERVICENAME.service
# lingering
loginctl enable-linger vagrant
```
