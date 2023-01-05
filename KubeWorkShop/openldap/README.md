
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