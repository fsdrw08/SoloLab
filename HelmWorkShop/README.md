https://github.com/kurokobo/awx-on-k3s
https://github.com/k8s-at-home/charts/tree/master/charts/stable/powerdns

export KUBECONFIG=/etc/rancher/k3s/k3s.yaml


sudo snap install helm --classic

# create name space
kubectl create namespace kube-dashboard
# add kubernete-dashboard repo
helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
# create cert
openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -keyout ./tls.key -out ./tls.crt -subj "/CN=dashboard.lab"
# install
helm install k8s-dashboard kubernetes-dashboard/kubernetes-dashboard -f /vagrant/HelmWorkShop/k8s-dashboard/values.yaml


# config traefik dashboard
# according to traefik's installation guide (https://doc.traefik.io/traefik/getting-started/install-traefik/#exposing-the-traefik-dashboard)
kubectl apply -f /vagrant/HelmWorkShop/traefik-dashboard/IngressRoute.yaml

# https://www.padok.fr/en/blog/traefik-kubernetes-certmanager?utm_source=pocket_mylist
kubectl apply -f /vagrant/HelmWorkShop/traefik-dashboard/auth.yaml

# add traefik providers.kubernetesingress.ingressclass
# https://rancher.com/docs/k3s/latest/en/helm/#customizing-packaged-components-with-helmchartconfig
# https://doc.traefik.io/traefik/providers/kubernetes-ingress/#ingressclass
cp /vagrant/HelmWorkShop/traefik-config/traefik-config.yaml /var/lib/rancher/k3s/server/manifests/traefik-config.yaml

# install cert-manager
# install the cert-manager CustomResourceDefinition resources (change the version refer from https://cert-manager.io/docs/installation/supported-releases/)
# kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.5.0/cert-manager.crds.yaml
# Create the namespace for cert-manager
kubectl create namespace cert-manager
# Add the Jetstack Helm repository
helm repo add jetstack https://charts.jetstack.io
# Install the cert-manager Helm chart
helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --set installCRDs=true \
  --create-namespace
# have a check
kubectl get pods --namespace cert-manager
# create issuer
kubectl apply -f /vagrant/HelmWorkShop/cert-manager/issuer-selfsigned.yaml

https://www.padok.fr/en/blog/traefik-kubernetes-certmanager?utm_source=pocket_mylist
https://crt.the-mori.com/2020-11-20-traefik-v2-letsencrypt-cert-manager-raspberry-pi-4-kubernetes

# create traefik-cert
kubectl apply -f /vagrant/HelmWorkShop/cert-manager/traefik-cert.yaml
# update traefik ingressroute
kubectl apply -f /vagrant/HelmWorkShop/traefik-dashboard/IngressRoute_update.yaml
# update traefik helmchart config
cp /vagrant/HelmWorkShop/traefik-config/traefik-config.yaml /var/lib/rancher/k3s/server/manifests/traefik-config.yaml


# add rancher helm repo
helm repo add rancher-stable https://releases.rancher.com/server-charts/stable

# Create a Namespace for Rancher
kubectl create namespace cattle-system

# Install cert-manager



# Install Rancher with Helm and rancher-generated cert
helm install rancher rancher-stable/rancher \
  --namespace cattle-system \
  --set hostname=rancher.lab \
  --set replicas=1
# Verify that the Rancher Server is Successfully Deployed
kubectl -n cattle-system rollout status deploy/rancher
kubectl get pods --namespace cattle-system

# add mojo2600 helm repo
helm repo add mojo2600 https://mojo2600.github.io/pihole-kubernetes/
helm install pihole mojo2600/pihole -f /vagrant/HelmWorkShop/pihole/values.yaml

<!-- # add bitnami helm repo 
helm repo add bitnami https://charts.bitnami.com/bitnami
# create pgsql namespace
kubectl create namespace pgsql
# install postgresql
helm install postgresql bitnami/postgresql --namespace pgsql -f /vagrant/HelmWorkShop/postgresql/values.yaml
kubectl get pods --namespace pgsql -->

<!-- # add runix helm repo 
helm repo add runix https://helm.runix.net
# install pgadmin
helm install pgadmin runix/pgadmin4 --namespace pgsql -f /vagrant/HelmWorkShop/pgadmin/values.yaml
kubectl describe pgadmin-pgadmin4-bf884f4c8-n59c2  --namespace pgsql -->

<!-- # create powerdns namespace
kubectl create namespace powerdns

# add k8s at home helm repo
helm repo add k8s-at-home https://k8s-at-home.com/charts/
# install powerdns 
helm install powerdns k8s-at-home/powerdns --namespace powerdns -f /vagrant/HelmWorkShop/powerdns/values-k8s-at-home.yaml


kubectl get pods --namespace powerdns
kubectl describe pod powerdns-598454f648-kgr5v -n powerdns


kubectl exec --stdin --tty powerdns-postgresql-0 -n powerdns -- /bin/bash
createdb -h localhost -p 5432 -U pdns pdns_admin
psql -U pdns
\l

https://doc.powerdns.com/authoritative/dnsupdate.html

# add halkeye helm repo
helm repo add halkeye https://halkeye.github.io/helm-charts/
# install powerdns-admin
helm install powerdnsadmin halkeye/powerdnsadmin -n powerdns -f /vagrant/HelmWorkShop/powerdns-admin/values.yaml
kubectl logs powerdnsadmin-86b467cf97-84p24  -n powerdns

helm repo add k8s-at-home https://k8s-at-home.com/charts/
helm repo add bitnami https://charts.bitnami.com/bitnami -->

# helm repo add longhorn https://charts.longhorn.io

helm repo update

# https://longhorn.io/docs/1.1.2/deploy/install/#installation-requirements
`sudo apk add bash curl findmnt blkid util-linux open-iscsi nfs-utils`
`sudo rc-update add iscsid #https://www.hiroom2.com/2018/08/29/alpinelinux-3-8-open-iscsi-en/`
`sudo rc-service iscsid start`

# https://www.claudiokuenzler.com/blog/955/rancher2-kubernetes-cluster-provisioning-fails-error-response-not-a-shared-mount
`sudo sh -c "cat >/etc/local.d/make-shared.start" <<EOF`
`#!/bin/ash`
`mount --make-shared /`
`exit`
`EOF`

# https://blog.csdn.net/ctwy291314/article/details/104634667
# https://lists.alpinelinux.org/~alpine/devel/%3CCAF-%2BOzABh_NPrTZ2oMFUKrsYmSE5obOadKTAth1HU5_OEZUxPQ%40mail.gmail.com%3E
`sudo chmod +x /etc/local.d/make-shared.start`
`sudo rc-update add local boot`
`sudo rc-service local start`

kubectl create namespace longhorn-system
helm install longhorn longhorn/longhorn --namespace longhorn-system -f /vagrant/HelmWorkShop/longhorn/values.yaml
kubectl get pods --namespace longhorn-system
kubectl describe pod longhorn-manager-c8vmh --namespace longhorn-system

helm repo update




helm install <powerdnsadmin> halkeye/powerdnsadmin -n powerdns -f /vagrant/HelmWorkShop/powerdns-admin/values.yaml
kubectl get pods --namespace powerdns

browser visit powerdns-admin.lab (the address which show in ./powerdns-admin/values.yaml .ingress.hosts.host)
create new user account
..
PDNS API URL: http://<the ip address shows in kubectl get services -n powerdns | grep powerdns-webserver>:<the port number shows in >
PDNS API KEY: <the string which show in ./powerdns/values .powerdns.API_KEY>

kubectl describe pods powerdns-postgresql-0 --namespace powerdns

helm install <pgsql-pdnsadmin> bitnami/postgresql -f ./pgsql-pdnsadmin/values.yaml

kubectl describe pod -A
kubectl get pods
kubectl logs <podname>
kubectl exec -it <podname> -- /bin/bash

kubectl get deploy -A