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

### Deploy LLDAP
Deploy the container
```shell
podman network create ldap_net
mkdir -p $HOME/infra/lldap/data
podman kube play /var/vagrant/KubeWorkShop/LLDAP/pod-lldap.yaml 
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

### Deploy Samba
Deploy the container
- Ref: 
  - [podman-kube-play - Create containers, pods and volumes based on Kubernetes YAML](https://docs.podman.io/en/latest/markdown/podman-kube-play.1.html#configmap-path)
```shell
mkdir -p $HOME/infra
podman network create samba_net
podman kube play /var/vagrant/KubeWorkShop/Samba/pod-samba.yaml \
    --configmap /var/vagrant/KubeWorkShop/Samba/cm-samba.yaml \
    --network samba_net
# to delete
podman kube down /var/vagrant/KubeWorkShop/Samba/pod-samba.yaml
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

### Deploy Vault

```shell
APP_DIR="vault"
mkdir -p $HOME/infra/$APP_DIR/
cp -r /var/vagrant/KubeWorkShop/Vault/data/ $HOME/infra/$APP_DIR/

podman kube play /var/vagrant/KubeWorkShop/Vault/pod-vault.yaml \
    --configmap /var/vagrant/KubeWorkShop/Vault/cm-vault.yaml
# to delete
podman kube down /var/vagrant/KubeWorkShop/Vault/pod-vault.yaml
podman volume prune -f

```

Enable container start up when system start (gen the unit file and pass to home path systemd, also lingering current user)
```shell
mkdir -p $HOME/.config/systemd/user
# generate the systemd unit file
SERVICENAME="vault-vault"
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

Config vault (get root token) from UI first (server_ip:8200/ui)
To get access to vault from cli, run commands in vault container:
```shell
podman exec -it vault-vault /bin/sh
export VAULT_ADDR=http://127.0.0.1:8200
export VAULT_TOKEN="the root token get from ui"
vault login $VAULT_TOKEN
vault auth list
```
Then refer [Build Your Own Certificate Authority (CA)](https://developer.hashicorp.com/vault/tutorials/secrets-management/pki-engine#step-1-generate-root-ca) to set up root ca

see [README.md](../TerraformWorkShop/Vault/PKI/README.md)


### Deploy Traefik
```shell
APP_DIR="traefik"
mkdir -p $HOME/infra/$APP_DIR/
cp -r /var/vagrant/KubeWorkShop/Traefik/conf/* $HOME/infra/$APP_DIR/

podman kube play /var/vagrant/KubeWorkShop/Traefik/pod-traefik.yaml

# delete traefik
podman kube down /var/vagrant/KubeWorkShop/Traefik/pod-traefik.yaml
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


<!-- ### Deploy FreeIPA
update [.\FreeIPA\data\ipa-server-install-options](FreeIPA/data/ipa-server-install-options) first,
ref: https://freeipa.readthedocs.io/en/latest/workshop/1-server-install.html
```shell
# update /etc/hosts, hostname must lower case
"192.168.255.31 ipa.infra.sololab ..."
# stop and disable systemd-resolved
# sudo systemctl stop systemd-resolved
# sudo systemctl disable systemd-resolved
# sudo systemctl enable --now systemd-resolved

APP_DIR="freeipa"
mkdir -p $HOME/infra/$APP_DIR
cp -r /var/vagrant/KubeWorkShop/FreeIPA/data/ $HOME/infra/$APP_DIR/

# !! need to update yaml file
podman kube play /var/vagrant/KubeWorkShop/FreeIPA/pod-freeipa.yaml 


# have a check
cat infra/freeipa/data/var/log/ipa-server-configure-first.log
cat infra/freeipa/data/var/log/ipaserver-install.log
tail -n 100 $HOME/infra/freeipa/data/var/log/ipaserver-install.log

# delete freeipa
podman kube down /var/vagrant/KubeWorkShop/FreeIPA/pod-freeipa.yaml

sudo rm -rf $HOME/infra/freeipa/data/
``` -->

### Deploy OpenLDAP & LDAP Account Manager
```shell
APP_DIR="openldap"
mkdir -p $HOME/infra/$APP_DIR/{data,certs,lam_config}
cp -r /var/vagrant/KubeWorkShop/openldap/certs/* $HOME/infra/$APP_DIR/certs/
cp -r /var/vagrant/KubeWorkShop/openldap/lam_config/* $HOME/infra/$APP_DIR/lam_config/
chmod -R 777 $HOME/infra/openldap/data/

podman kube play /var/vagrant/KubeWorkShop/openldap/pod-openldap.yaml \
    --configmap /var/vagrant/KubeWorkShop/openldap/cm-lam_env.yaml \
    --configmap /var/vagrant/KubeWorkShop/openldap/cm-openldap_env.yaml \
    --configmap /var/vagrant/KubeWorkShop/openldap/cm-openldap_schema.yaml 


APP_DIR="openldap"
mkdir -p $HOME/infra/$APP_DIR/{data,schema,ldifs,certs}
cp -r /var/vagrant/KubeWorkShop/openldap/schema/* $HOME/infra/$APP_DIR/schema/
cp -r /var/vagrant/KubeWorkShop/openldap/ldifs/* $HOME/infra/$APP_DIR/ldifs/
cp -r /var/vagrant/KubeWorkShop/openldap/certs/* $HOME/infra/$APP_DIR/certs/
chmod -R 777 $HOME/infra/openldap/data/


# install podman-compose first
sudo dnf install podman-compose -y

cd /var/vagrant/KubeWorkShop/openldap/ && podman-compose up -d
cd /var/vagrant/KubeWorkShop/openldap/ && podman-compose down

podman kube play /var/vagrant/KubeWorkShop/openldap/pod-openldap.yaml \
    --configmap /var/vagrant/KubeWorkShop/openldap/cm-openldap_env.yaml \
    --configmap /var/vagrant/KubeWorkShop/openldap/cm-openldap_schema.yaml \
    --configmap /var/vagrant/KubeWorkShop/openldap/cm-lum_env.yaml 

podman kube down /var/vagrant/KubeWorkShop/openldap/pod-openldap.yaml
podman volume prune -f
sudo rm -rf $HOME/infra/openldap/*
```
