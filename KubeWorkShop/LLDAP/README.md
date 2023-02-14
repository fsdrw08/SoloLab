
### Deploy LLDAP
Deploy the container
```shell
podman network create ldap_net
mkdir -p $HOME/infra/lldap/data
podman kube play /var/vagrant/KubeWorkShop/LLDAP/pod-lldap.yaml 
podman kube play /var/vagrant/KubeWorkShop/LLDAP/pod-lldap.yaml \
    --userns=keep-id

cp /var/vagrant/KubeWorkShop/Traefik/conf/dynamic/traefik-lldap.yaml $HOME/infra/traefik/dynamic/
# to delete
podman kube down /var/vagrant/KubeWorkShop/LLDAP/pod-lldap.yaml
rm -rf $HOME/infra/lldap/data/*
```

Enable container start up when system start (gen the unit file and pass to home path systemd, also lingering current user)
- Ref: 
  - [[Solved] How to Auto-starting rootless pods using systemd](https://access.redhat.com/discussions/5733161)
  - [12.1. Enabling systemd services](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/9/html-single/building_running_and_managing_containers/index#proc_enabling-systemd-services_assembly_porting-containers-to-systemd-using-podman)
  - [podman-generate-systemd - Generate systemd unit file(s) for a container or pod](https://docs.podman.io/en/latest/markdown/podman-generate-systemd.1.html)
```shell
mkdir -p $HOME/.config/systemd/user
# generate the systemd unit file
podman generate systemd --name lldap-lldap > $HOME/.config/systemd/user/lldap-lldap.service
# have a check
cat $HOME/.config/systemd/user/lldap-lldap.service
systemctl --user enable lldap-lldap.service

# to disable this service
systemctl --user disable lldap-lldap.service
rm -f $HOME/.config/systemd/user/lldap-lldap.service
```