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

see [README.md](../../TerraformWorkShop/Vault/PKI/README.md)
