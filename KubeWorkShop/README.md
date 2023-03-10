The main propose of KubeWorkShop is to deploy infra related service (ldap, smb, pki, dns) to sololab project

### Enable CPU or CPUSET limit delegation for all users
In order to set pod resource limit for all pods
- Ref:
    - [Running containers with resource limits fails with a permissions error](https://github.com/containers/podman/blob/main/troubleshooting.md#26-running-containers-with-resource-limits-fails-with-a-permissions-error)
    - [cgroups v2: cgroup controllers not delegated to non-privileged users on CentOS Stream (8)](https://unix.stackexchange.com/questions/624428/cgroups-v2-cgroup-controllers-not-delegated-to-non-privileged-users-on-centos-s)  

- Enable CPU or CPUSET limit delegation for all users
```shell
sudo mkdir -p /etc/systemd/system/user@.service.d
sudo sh -c "cat >/etc/systemd/system/user@.service.d/delegate.conf<<EOF
[Service]
Delegate=memory pids cpu cpuset
EOF"
# sudo reboot
```

### Low down the unprivileged port
For samba deployment (samba require port 443 which lower than 1024 in the limit set)
```shell
sudo sh -c "echo 'net.ipv4.ip_unprivileged_port_start=53'>>/etc/sysctl.conf"
# sudo reboot
```

### Enable memlock for all users
For vault deployment, hashicorp vault require memory lock for the container
Ref:
    - [Question: How to run hashicorp vault as rootless container](https://github.com/containers/podman/issues/10051)
```shell
sudo sh -c "cat >>/etc/security/limits.conf<<EOF
*                hard    memlock         -1
*                soft    memlock         -1
EOF"
# sudo reboot
```

### Enable lingering
ref: 
    - [Installation of generated systemd unit files](https://docs.podman.io/en/latest/markdown/podman-generate-systemd.1.html#installation-of-generated-systemd-unit-files)
```shell
loginctl enable-linger vagrant
```


### Deploy Samba
Deploy the container
- Ref: 
  - [podman-kube-play - Create containers, pods and volumes based on Kubernetes YAML](https://docs.podman.io/en/latest/markdown/podman-kube-play.1.html#configmap-path)
```shell
mkdir -p $HOME/infra
# podman network create samba_net
podman kube play /var/vagrant/KubeWorkShop/Samba/aio-samba.yaml

podman kube play /var/vagrant/KubeWorkShop/Samba/pod-samba.yaml \
    --configmap /var/vagrant/KubeWorkShop/Samba/cm-samba.yaml 

# to delete
podman kube down /var/vagrant/KubeWorkShop/Samba/pod-samba.yaml
podman kube down /var/vagrant/KubeWorkShop/Samba/aio-samba.yaml --force
```

Enable container start up when system start (gen the unit file and pass to home path systemd, also lingering current user)
```shell
mkdir -p $HOME/.config/systemd/user
# generate the systemd unit file
SERVICENAME="samba-samba"
echo $SERVICENAME
podman generate systemd --name $SERVICENAME > $HOME/.config/systemd/user/$SERVICENAME.service
# have a check
cat $HOME/.config/systemd/user/$SERVICENAME.service
systemctl --user enable $SERVICENAME.service
# lingering
loginctl enable-linger vagrant
```



### Deploy FreeIPA
update [.\FreeIPA\data\ipa-server-install-options](FreeIPA/data/ipa-server-install-options) first,
ref: https://freeipa.readthedocs.io/en/latest/workshop/1-server-install.html
```shell
# update /etc/hosts, hostname must lower case
# "192.168.255.31 ipa.infra.sololab ..."

# sudo bash -c "echo '192.168.255.31 ipa.infra.sololab' >> /etc/hosts"

APP_DIR="FreeIPA"
mkdir -p $HOME/infra/$APP_DIR/data
cp -r /var/vagrant/KubeWorkShop/$APP_DIR/data/ipa-server-install-options $HOME/infra/$APP_DIR/data/

cp -r /var/vagrant/KubeWorkShop/$APP_DIR/data/ $HOME/infra/$APP_DIR/

chmod -R 777 $HOME/infra/$APP_DIR/data/

# !! need to update yaml file
podman kube play /var/vagrant/KubeWorkShop/$APP_DIR/pod-freeipa.yaml 
podman kube play /var/vagrant/KubeWorkShop/$APP_DIR/aio-freeipa.yaml 


mkdir -p $HOME/.config/systemd/user
# generate the systemd unit file
SERVICENAME="freeipa-freeipa"
echo $SERVICENAME
podman generate systemd --name $SERVICENAME > $HOME/.config/systemd/user/$SERVICENAME.service
# have a check
cat $HOME/.config/systemd/user/$SERVICENAME.service
systemctl --user enable $SERVICENAME.service
# lingering
loginctl enable-linger vagrant


# have a check
cat infra/$APP_DIR/data/var/log/ipa-server-configure-first.log
cat infra/$APP_DIR/data/var/log/ipaserver-install.log
tail -n 500 $HOME/infra/$APP_DIR/data/var/log/ipaserver-install.log

tail -n 300 $HOME/infra/$APP_DIR/data/var/log/pki/pki-ca-spawn.20230102132637.log

sudo cat  ~/.local/share/containers/storage/volumes/freeipa/_data/var/log/dirsrv/slapd-INFRA-SOLOLAB/errors
# to delete freeipa
podman kube down /var/vagrant/KubeWorkShop/$APP_DIR/pod-freeipa.yaml

sudo rm -rf $HOME/infra/freeipa/data/

SERVICENAME="freeipa-freeipa"
echo $SERVICENAME
systemctl --user disable $SERVICENAME.service


```

config dns dynamic update
ref: 
- https://astrid.tech/2021/04/18/0/k8s-freeipa-dns/
- https://forum.netgate.com/topic/153869/dnssec-keygen-unknown-algorithm-hmac-md5/3
- https://www.freeipa.org/page/Howto/DNS_updates_and_zone_transfers_with_TSIG
```shell
podman exec -it freeipa-freeipa /bin/bash
echo "$(tsig-keygen sololab)" >> /etc/named/ipa-ext.conf
cat /etc/named/ipa-ext.conf
# key "sololab" {
#         algorithm hmac-sha256;
#         secret "j/2DR2zkVAyDHL2XjE731sMt9s6cmRhXE6niScAgHA0=";
# };
cat << EOF >> /etc/named/ipa-ext.conf
key "keySololab" {
        algorithm hmac-sha256;
        secret "j/2DR2zkVAyDHL2XjE731sMt9s6cmRhXE6niScAgHA0=";
};
EOF

kinit admin
# ipa dnszone-mod infra.sololab. --update-policy="<grant|deny> <keyname> <nametype: name, subdomain, wildcard, self> infra.sololab ANY;"
ipa dnszone-mod infra.sololab. --update-policy="grant keySololab wildcard * ANY;"
ipa-acme-manage enable
```
then go to [..\TerraformWorkShop\LDAP](..\TerraformWorkShop\LDAP), run terraform to apply some ldap resources (service account)
-ref: 
    - [Jenkins Authentication With Keycloak](https://thomascfoulds.com/2020/04/09/jenkins-authentication-with-keycloak.html)
    - [Setting up Containerized FreeIPA & KeyCloak Single Sign-On](https://blog.sakuragawa.moe/setting-up-containerized-freeipa-keycloak-single-sign-on/)
```powershell
terraform init
terraform apply --auto-approve
```

### Deploy Traefik
```shell
APP_DIR="traefik"
mkdir -p $HOME/infra/$APP_DIR/
cp -r /var/vagrant/KubeWorkShop/$APP_DIR/conf/* $HOME/infra/$APP_DIR/
cp $HOME/infra/freeipa/data/etc/ipa/ca.crt $HOME/infra/traefik/
sudo nmcli con mod 'eth0' IPv4.dns "192.168.255.31"
sudo systemctl restart NetworkManager
podman kube play /var/vagrant/KubeWorkShop/traefik/pod-traefik.yaml 

# delete traefik
podman kube down /var/vagrant/KubeWorkShop/traefik/pod-traefik.yaml
rm -rf $HOME/infra/traefik/*
```

Enable container start up when system start (gen the unit file and pass to home path systemd, also lingering current user)
```shell
mkdir -p $HOME/.config/systemd/user
# generate the systemd unit file
SERVICENAME="traefik-traefik"
echo $SERVICENAME
podman generate systemd --name $SERVICENAME > $HOME/.config/systemd/user/$SERVICENAME.service
# have a check
cat $HOME/.config/systemd/user/$SERVICENAME.service
systemctl --user enable $SERVICENAME.service
# lingering
loginctl enable-linger vagrant

# delete
systemctl --user disable $SERVICENAME.service
```


### deploy pgadmin4
```shell
APP_DIR="pgadmin4"
mkdir -p $HOME/infra/$APP_DIR/data
chmod -R 777 $HOME/infra/$APP_DIR/data

podman kube play /var/vagrant/KubeWorkShop/pgadmin4/pod-pgadmin4.yaml 

cp /var/vagrant/KubeWorkShop/pgadmin4/traefik-pgadmin4.yaml $HOME/infra/traefik/dynamic/

# delete
podman kube down /var/vagrant/KubeWorkShop/pgadmin4/pod-pgadmin4.yaml 
sudo rm -rf $HOME/infra/$APP_DIR/data

# set auto start
mkdir -p $HOME/.config/systemd/user
# generate the systemd unit file
SERVICENAME="pgadmin4-pgadmin4"
echo $SERVICENAME
podman generate systemd --name $SERVICENAME > $HOME/.config/systemd/user/$SERVICENAME.service
# have a check
cat $HOME/.config/systemd/user/$SERVICENAME.service
systemctl --user enable $SERVICENAME.service
# lingering
loginctl enable-linger vagrant
```

### deploy keycloak and postgresql
```shell
APP_DIR="keycloak"
mkdir -p $HOME/infra/$APP_DIR/postgresql
chmod -R 777 $HOME/infra/$APP_DIR/postgresql

podman kube play /var/vagrant/KubeWorkShop/keycloak/pod-keycloak_bitnami.yaml \
    --configmap /var/vagrant/KubeWorkShop/keycloak/cm-keycloak.yaml 

podman kube play /var/vagrant/KubeWorkShop/keycloak/pod-keycloak_offical.yaml \
    --configmap /var/vagrant/KubeWorkShop/keycloak/cm-keycloak.yaml 

# delete
podman kube down /var/vagrant/KubeWorkShop/keycloak/pod-keycloak.yaml 

podman kube down /var/vagrant/KubeWorkShop/keycloak/pod-keycloak_new.yaml 

sudo rm -rf $HOME/infra/$APP_DIR/data

# set auto start
mkdir -p $HOME/.config/systemd/user
# generate the systemd unit file
SERVICENAME="keycloak"
podman generate systemd --files --name $SERVICENAME
cp pod-keycloak.service container-keycloak-keycloak.service container-keycloak-postgresql.service $HOME/.config/systemd/user/

# podman generate systemd --name $SERVICENAME > $HOME/.config/systemd/user/$SERVICENAME.service
# have a check
cat $HOME/.config/systemd/user/pod-keycloak.service
systemctl --user enable pod-keycloak.service


systemctl --user disable pod-$SERVICENAME.service
# lingering
loginctl enable-linger vagrant
```