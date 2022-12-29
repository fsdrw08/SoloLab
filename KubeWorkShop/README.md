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
sudo sh -c "echo 'net.ipv4.ip_unprivileged_port_start=80'>>/etc/sysctl.conf"
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
cp -r /var/vagrant/KubeWorkShop/$APP_DIR/conf/* $HOME/infra/$APP_DIR/

podman kube play /var/vagrant/KubeWorkShop/traefik/pod-traefik.yaml

# delete traefik
podman kube down /var/vagrant/KubeWorkShop/traefik/pod-traefik.yaml
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


### Deploy FreeIPA
update [.\FreeIPA\data\ipa-server-install-options](FreeIPA/data/ipa-server-install-options) first,
ref: https://freeipa.readthedocs.io/en/latest/workshop/1-server-install.html
```shell
# update /etc/hosts, hostname must lower case
"192.168.255.32 ipa.infra.sololab ..."
# stop and disable systemd-resolved
# sudo systemctl stop systemd-resolved
# sudo systemctl disable systemd-resolved
# sudo systemctl enable --now systemd-resolved

APP_DIR="freeipa"
mkdir -p $HOME/infra/$APP_DIR/data
cp -r /var/vagrant/KubeWorkShop/$APP_DIR/data/ipa-server-install-options $HOME/infra/$APP_DIR/data/

cp -r /var/vagrant/KubeWorkShop/$APP_DIR/data/ $HOME/infra/$APP_DIR/

chmod -R 777 $HOME/infra/freeipa/data/

# !! need to update yaml file
podman kube play /var/vagrant/KubeWorkShop/freeipa/pod-freeipa.yaml 


# have a check
cat infra/freeipa/data/var/log/ipa-server-configure-first.log
cat infra/freeipa/data/var/log/ipaserver-install.log
tail -n 500 $HOME/infra/freeipa/data/var/log/ipaserver-install.log

tail -n 300 $HOME/infra/freeipa/data/var/log/pki/pki-ca-spawn.20221228024225.log
# delete freeipa
podman kube down /var/vagrant/KubeWorkShop/freeipa/pod-freeipa.yaml

sudo rm -rf $HOME/infra/freeipa/data/
```

config dns dynamic update
ref: 
- https://astrid.tech/2021/04/18/0/k8s-freeipa-dns/
- https://forum.netgate.com/topic/153869/dnssec-keygen-unknown-algorithm-hmac-md5/3
- https://www.freeipa.org/page/Howto/DNS_updates_and_zone_transfers_with_TSIG
```shell
podman exec -it freeipa-freeipa /bin/bash
echo "$(tsig-keygen sololab)" >> /etc/named/ipa-ext.conf
cat /etc/named.conf
# key "sololab" {
#         algorithm hmac-sha256;
#         secret "CdfWki3NHLLizpZ9nvK/wqojh//xENcu8zX8aYfcOds=";
# };
kinit admin
# ipa dnszone-mod infra.sololab. --update-policy="<grant|deny> <keyname> <nametype: name, subdomain, wildcard, self> infra.sololab ANY;"
ipa dnszone-mod infra.sololab. --update-policy="grant sololab wildcard * ANY;"
```

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

### Deploy powerdns
ref: 
    - [pdns/Dockerfile-auth](https://github.com/PowerDNS/pdns/blob/master/Dockerfile-auth)
    - [pdns/dockerdata/startup.py](https://github.com/PowerDNS/pdns/blob/master/dockerdata/startup.py)
    - [powerdns-helm/backend/pdns.j2](https://github.com/hwaastad/powerdns-helm/blob/308eec60b80e50dc5f27f0562e566c6fa9ad3354/backend/pdns.j2)
how does the container work:
startup.py -> pdns_server-startup  

apiconftemplate -> jinja2.Template(apiconftemplate).render(apikey=apikey) -> open(conffile, 'w').write(webserver_conf) -> conffile.content
```conf
api
api-key={{ apikey }}
webserver
webserver-address=0.0.0.0
webserver-allow-from=0.0.0.0/0
webserver-password={{ apikey }}
```
templatedestination (/etc/`<role, "powerdns" for auth>`/pdns.d) + _api.conf -> conffile.path

templateroot (/etc/`<role>`/templates.d) + templateFile (the filename assign from ENV VAR `TEMPLATE_FILES`) + .j2 -> jinja2.Template.render(os.environ) ->  target.content
```conf

```
templatedestination (/etc/`<role>`/pdns.d) + templateFile (the filename assign from ENV VAR `TEMPLATE_FILES`) + .conf -> target.path

```shell
APP_DIR="powerdns powerdns-admin"
for APP in $APP_DIR; do \
mkdir -p $HOME/infra/$APP/data; chmod -R 777 $HOME/infra/$APP/data; \
done

podman kube play /var/vagrant/KubeWorkShop/powerdns/pod-powerdns.yaml \
    --configmap /var/vagrant/KubeWorkShop/powerdns/cm-powerdns.yaml

podman kube down /var/vagrant/KubeWorkShop/powerdns/pod-powerdns.yaml  
```

### install dex
```shell
APP_DIR="dex"
mkdir -p $HOME/infra/$APP_DIR/data

podman kube play /var/vagrant/KubeWorkShop/dex/pod-dex.yaml \
    --configmap /var/vagrant/KubeWorkShop/dex/cm-dex.yaml
```
