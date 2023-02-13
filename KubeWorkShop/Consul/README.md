### Deploy Consul
Deploy the container
```shell
mkdir -p $HOME/infra/consul/data

# add firewalld service
sudo firewall-cmd --permanent --new-service-from-file=/var/vagrant/KubeWorkShop/Consul/firewalld-consul.xml --name=consul
sudo firewall-cmd --permanent --add-service=consul
sudo firewall-cmd --reload

podman kube play /var/vagrant/KubeWorkShop/Consul/pod-consul_new.yaml \
    --configmap /var/vagrant/KubeWorkShop/Consul/cm-consul.yaml \
    --userns=keep-id

podman kube play /var/vagrant/KubeWorkShop/Consul/pod-consul_pvc.yaml \
    --configmap /var/vagrant/KubeWorkShop/Consul/cm-consul.yaml \
    --userns=keep-id

mkdir -p $HOME/.local/share/containers/log/
podman kube play /var/vagrant/KubeWorkShop/Consul/pod-consul_new.yaml \
    --configmap /var/vagrant/KubeWorkShop/Consul/cm-consul.yaml \
    --userns=keep-id \
    --log-driver k8s-file \
    --log-opt path=/home/vagrant/.local/share/containers/log/consul.json \
    --log-opt max-size=10mb


# to delete
podman kube down /var/vagrant/KubeWorkShop/Consul/pod-consul_new.yaml
# remove from firewalld
sudo firewall-cmd --permanent --remove-service=consul
sudo firewall-cmd --permanent --delete-service=consul
sudo firewall-cmd --reload
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
