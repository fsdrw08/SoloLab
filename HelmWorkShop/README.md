https://github.com/kurokobo/awx-on-k3s
https://github.com/k8s-at-home/charts/tree/master/charts/stable/powerdns

export KUBECONFIG=/etc/rancher/k3s/k3s.yaml


sudo snap install helm --classic

helm repo add k8s-at-home https://k8s-at-home.com/charts/
helm repo add halkeye https://halkeye.github.io/helm-charts/
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo add longhorn https://charts.longhorn.io

helm repo update

# https://longhorn.io/docs/1.1.2/deploy/install/#installation-requirements
`sudo apk add bash curl findmnt blkid util-linux open-iscsi nfs-utils`
`sudo rc-update add iscsid #https://www.hiroom2.com/2018/08/29/alpinelinux-3-8-open-iscsi-en/`
`sudo rc-service iscsid start`

# https://www.claudiokuenzler.com/blog/955/rancher2-kubernetes-cluster-provisioning-fails-error-response-not-a-shared-mount
`sudo cat << EOF >/etc/local.d/make-shared.start`
`#!/bin/ash`
`mount --make-shared /`
`exit`
`EOF`

# https://blog.csdn.net/ctwy291314/article/details/104634667
`sudo chmod +x /etc/local.d/make-shared.start`
`sudo rc-update add local`
`sudo rc-service local start`

kubectl create namespace longhorn-system
helm install longhorn longhorn/longhorn --namespace longhorn-system
kubectl get pods --namespace longhorn-system
kubectl describe pod longhorn-manager-gvj6g --namespace longhorn-system

helm repo update

helm install <powerdns> k8s-at-home/powerdns -f /vagrant/HelmWorkShop/powerdns/values.yaml
helm install <pgsql-pdnsadmin> bitnami/postgresql -f ./pgsql-pdnsadmin/values.yaml
helm install <powerdnsadmin> halkeye/powerdnsadmin -f ./powerdns-admin/values.yamlx

kubectl describe pod -A
kubectl get pods
kubectl logs <podname>
kubectl exec -it <podname> -- /bin/bash

