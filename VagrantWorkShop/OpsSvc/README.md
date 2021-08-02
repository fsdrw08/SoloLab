https://github.com/kurokobo/awx-on-k3s
https://github.com/k8s-at-home/charts/tree/master/charts/stable/powerdns

export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

sudo snap install helm --classic
helm repo add k8s-at-home https://k8s-at-home.com/charts/
helm repo add halkeye https://halkeye.github.io/helm-charts/
helm repo add bitnami https://charts.bitnami.com/bitnami

helm repo update

helm install <powerdns> k8s-at-home/powerdns -f ./powerdns/values.yaml
helm install <pgsql-pdnsadmin> bitnami/postgresql -f ./pgsql-pdnsadmin/values.yaml
helm install <powerdnsadmin> halkeye/powerdnsadmin -f ./powerdns-admin/values.yamlx

kubectl describe pod -A
kubectl get pods
kubectl logs <podname>
kubectl exec -it <podname> -- /bin/bash

