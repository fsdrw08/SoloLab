## Prepare (Install / Upgrade) k3s:
Ref: 
- https://github.com/k3s-io/k3s/issues/389
- https://rancher.com/docs/k3s/latest/en/upgrades/basic/
  ```
  curl -sfL https://get.k3s.io | INSTALL_K3S_CHANNEL=latest INSTALL_K3S_EXEC="--write-kubeconfig-mode 644" sh -
  ```

- Export k3s KUBECONFIG
  ```
  export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
  ```
- Install Helm
  ```
  sudo snap install helm --classic
  ```

- k3s config parameter:  
  Ref: 
  - [Set the time zone of your Kubernetes Pod together](https://qiita.com/ussvgr/items/0190bab3cc7d16c0116c)  

  For openrc base system (alpine linux): /etc/init.d/k3s  
  For systemd base system (debian, rhel): /etc/systemd/system/k3s.service

## Config kubectl bash auto completion in alpine
- Install and config bash completion  
Ref: [How to enable bash command autocomplete on Alpine Linux](https://www.cyberciti.biz/faq/alpine-linux-enable-bash-command-autocomplete/)
  - Install bash completion
    ```
    apk add bash-completion
    ```

  - Edit the `~/.bash_profile` and append the line: 
    ```
    echo 'source /etc/profile.d/bash_completion.sh' >> ~/.bash_profile
    ```

  - Set up bash as a default shell by editing the `/etc/passwd`
    ```
    <username>:...:...:...:<user homepath>:/bin/bash
    ```

- Config kubectl bash auto completion  
Ref: [bash auto-completion on Linux
](https://kubernetes.io/docs/tasks/tools/included/optional-kubectl-configs-bash-linux/)
  - Source the completion script in your `~/.bashrc` file  
    ```
    echo 'source <(kubectl completion bash)' >>~/.bashrc
    ```
  - Add the completion script to the `/etc/bash_completion.d` directory:
    ```
    sudo mkdir -p /etc/bash_completion.d
    kubectl completion bash >/etc/bash_completion.d/kubectl
    ```
## Install ansible awx on k3s
Ref:  
- https://github.com/kurokobo/awx-on-k3s  
- https://github.com/k8s-at-home/charts/tree/master/charts/stable/powerdns <- use pihole or Technitium DNS instead

<!-- ## Enable podpreset
Ref:  
- https://lemonlzy.cn/2020/07/21/Pod-Preset/ -->

## Use Cert-manager to manage certificates in cluster
- Add the Jetstack Helm repository:  
  ```
  helm repo add jetstack https://charts.jetstack.io
  ```

- Install cert-manager and create related namespace via Helm chart  
  Ref: 
  - [Install cert-manager](https://cert-manager.io/docs/installation/helm/#4-install-cert-manager)
  ```
  helm install cert-manager jetstack/cert-manager \
    --namespace cert-manager \
    --set installCRDs=true \
    --create-namespace
  ```

- have a check  
  ```
  kubectl get pods --namespace cert-manager
  ```

- Create self sign issuer  
  - Ref:  
    - https://crt.the-mori.com/2020-11-20-traefik-v2-letsencrypt-cert-manager-raspberry-pi-4-kubernetes  
    - [Use Cert-manager to manage certificates in your cluster](https://www.padok.fr/en/blog/traefik-kubernetes-certmanager#use)  
    - [/HelmWorkShop/cert-manager/issuer-selfsigned.yaml](./cert-manager/issuer-selfsigned.yaml)
  ```
  kubectl apply -f /vagrant/HelmWorkShop/cert-manager/issuer-selfsigned.yaml
  ```

- Create k3s ca key pair
  - Ref:
    - [Manipulating text at the command line with sed](https://www.redhat.com/sysadmin/manipulating-text-sed)
    - [Appending to end of a line using 'sed'](https://askubuntu.com/questions/537967/appending-to-end-of-a-line-using-sed)
    - [sed conditionally append to line after matching pattern](https://stackoverflow.com/questions/55633885/sed-conditionally-append-to-line-after-matching-pattern)
    - [How to configure my own CA for k3s](https://github.com/k3s-io/k3s/issues/1868#issuecomment-639690634)
    - [Cert-manager CA](https://cert-manager.io/docs/configuration/ca/)
  ```
  sed -i -e "/tls.crt:/s/$/$(cat /var/lib/rancher/k3s/server/tls/server-ca.crt | base64 -w0)/" -e "/tls.key:/s/$/$(cat /var/lib/rancher/k3s/server/tls/server-ca.key | base64 -w0)/" /vagrant/HelmWorkShop/cert-manager/ca-key-pair.yaml
  cat /vagrant/HelmWorkShop/cert-manager/ca-key-pair.yaml
  kubectl apply -f /vagrant/HelmWorkShop/cert-manager/ca-key-pair.yaml
  ```

- Create k3s ca issuer
  ```
  kubectl apply -f /vagrant/HelmWorkShop/cert-manager/issuer-ca.yaml
  ```

## Install and config dex
- Add dex helm repo and update helm chart  
  ```
  helm repo add dex https://charts.dexidp.io
  helm repo update
  ```
- Create dex namespace
  ```
  kubectl create namespace dex
  ```

- Create self sign tls cert for dex
  - Ref:
    - [dex-cert-self.yaml](./HelmWorkShop/cert-manager/dex-cert-self.yaml)
  ```
  kubectl apply -f /vagrant/HelmWorkShop/cert-manager/dex-cert-self.yaml
  ```

- Install dex via Helm chart (include self sign cert create, namespace create)  
  - Ref:
    - [Setting secrets for Dex in Jenkins-X and Kubernetes](https://blog.lysender.com/2021/09/setting-secrets-for-dex-in-jenkins-x-and-kubernetes/)
  ```
  helm install dex dex/dex \
    --namespace dex \
    --create-namespace \
    --values /vagrant/HelmWorkShop/dex/value.yaml
  ```
  - Or update the values
  ```
  helm upgrade dex dex/dex \
    -f /vagrant/HelmWorkShop/dex/value.yaml \
    --namespace dex
  ```
  - Or uninstall the dex helm chart and delete dex namespace, then recreate again
  ```
  helm uninstall dex -n dex
  kubectl delete namespace dex
  ```

- (no need?) Add ingress route for dex
  - Ref:
    - [还不会Traefik？看完这篇文章，你就彻底搞懂了~](https://z.itpub.net/article/detail/B4F2CC264BEB02610B23F8D0E9BA91FB)
    - [Unable to run dex serve command](https://github.com/dexidp/dex/issues/1257#issuecomment-413523548)
  ```
  kubectl apply -f /vagrant/HelmWorkShop/dex/dex-ingressRoute.yaml
  ```

- (no need?) Export Dex certificate  
  - Ref:  
    - [Decode Secrets](https://phoenixnap.com/kb/kubernetes-secrets#ftoc-heading-6)  
    - [How to Configure Dex and Gangway for Active Directory Authentication in TKG](https://little-stuff.com/2020/06/23/how-to-configure-dex-and-gangway-for-active-directory-authentication-in-tkg/)
  ```
  kubectl get secret dex.lab -n dex -o jsonpath='{.data}'
  ```

- (no need? dex had already add "kube-root-ca.crt" cm in it's own ns) Create ConfigMap (root ca and key) for loginapp
  - Ref:
    - https://github.com/fydrah/loginapp/tree/master/helm/loginapp#prerequisites
  ```
  sudo cat /var/lib/rancher/k3s/server/tls/server-ca.crt
  vi /vagrant/HelmWorkShop/loginapp/ca-cm.yaml
  kubectl create -f /vagrant/HelmWorkShop/loginapp/ca-cm.yaml
  ```

- Config and install fydrah loginapp
  - Ref:
    - [loginapp](https://github.com/fydrah/loginapp/tree/master/helm/loginapp#loginapp)
  
  - Config loginapp value, add certificate-authority data
  ```
  yq -i e '.config.clusters[0].certificate-authority = "'"$(sudo cat /var/lib/rancher/k3s/server/tls/server-ca.crt)"'"' /vagrant/HelmWorkShop/loginapp/values.yaml
  ```

  - add helm repo and install loginapp
  ```
  helm repo add fydrah-stable https://charts.fydrah.com
  helm repo update
  helm install loginapp fydrah-stable/loginapp \
    --namespace dex \
    --values /vagrant/HelmWorkShop/loginapp/values.yaml
  ```
  or upgrade 
  ```
  helm upgrade loginapp fydrah-stable/loginapp \
  --namespace dex \
  --values /vagrant/HelmWorkShop/loginapp/values.yaml
  ```

- add rbac for dex local staticPasswords account
  ```
  kubectl apply -f /vagrant/HelmWorkShop/dex/RBAC.yaml
  ```

- Modify api server arg config to make dex as oidc provider  
  - Ref:
    - [K3s customized flags](https://rancher.com/docs/k3s/latest/en/installation/install-options/server-config/#customized-flags)
    - [How to Secure Your Kubernetes Cluster with OpenID Connect  and RBAC](https://developer.okta.com/blog/2021/11/08/k8s-api-server-oidc#k3d)
    - [Set the time zone of your Kubernetes Pod together](https://qiita.com/ussvgr/items/0190bab3cc7d16c0116c) 
    - [How to Secure Your Kubernetes Cluster with OpenID Connect and RBAC](https://developer.okta.com/blog/2021/11/08/k8s-api-server-oidc#kubeadm)
  - add following arg in /etc/init.d/k3s (for k3s in apline linux)  
  ```
  '--kube-apiserver-arg' \
  'oidc-issuer-url=https://dex.lab' \
  '--kube-apiserver-arg' \
  'oidc-client-id=kubernetes' \
  '--kube-apiserver-arg' \
  'oidc-ca-file=/var/lib/rancher/k3s/server/tls/server-ca.crt' \
  '--kube-apiserver-arg' \
  'oidc-username-claim=email' \
  '--kube-apiserver-arg' \
  'oidc-groups-claim=groups' \
  ```
   
- unset kubectl config
  - Ref: 
    - [Kubernetes: How do I delete clusters and contexts from kubectl config?](https://stackoverflow.com/questions/37016546/kubernetes-how-do-i-delete-clusters-and-contexts-from-kubectl-config)
  ```
  kubectl config unset users.gke_project_zone_name
  kubectl config unset contexts.aws_cluster1-kubernetes
  kubectl config unset clusters.foobar-baz
  ```

- login to https://loginapp.lab and set with new config
## Config traefik dashboard
- Enable traefik dashboard, by defining and applying an IngressRoute CRD  
  - Ref: 
    - [Exposing the Traefik dashboard](https://doc.traefik.io/traefik/getting-started/install-traefik/#exposing-the-traefik-dashboard)  
    - [/HelmWorkShop/traefik-dashboard/IngressRoute.yaml](traefik-dashboard/IngressRoute.yaml)
  ```
  kubectl apply -f /vagrant/HelmWorkShop/traefik-dashboard/IngressRoute.yaml
  ```

- Secure access to Traefik using basic auth (add secret and add traefik basic auth middleware point to that secret)  
  - Ref: 
    - [How to configure Traefik on Kubernetes with Cert-manager?](https://www.padok.fr/en/blog/traefik-kubernetes-certmanager?utm_source=pocket_mylist)  
    - [/HelmWorkShop/traefik-dashboard/auth.yaml](traefik-dashboard/auth.yaml)
  ```
  kubectl apply -f /vagrant/HelmWorkShop/traefik-dashboard/auth.yaml
  ```

- Add traefik providers.kubernetesingress.ingressclass  
  - Ref:  
    - [Customizing Packaged Components with HelmChartConfig](https://rancher.com/docs/k3s/latest/en/helm/#customizing-packaged-components-with-helmchartconfig)
    - [traefik ingressClass](https://doc.traefik.io/traefik/providers/kubernetes-ingress/#ingressclass)  
    - [/HelmWorkShop/traefik-config/traefik-config.yaml](traefik-config/traefik-config.yaml)
  ```
  sudo cp /vagrant/HelmWorkShop/traefik-config/traefik-config.yaml \
    /var/lib/rancher/k3s/server/manifests/traefik-config.yaml
  ```


- Issue traefik-cert (by cert-manager self sign issuer)  
  - Ref:
    - [/HelmWorkShop/cert-manager/traefik-cert-self.yaml](cert-manager/traefik-cert-self.yaml)
  ```
  kubectl apply -f /vagrant/HelmWorkShop/cert-manager/traefik-cert-self.yaml
  ```

- Update traefik ingressroute (with the traefik auth middleware create in previous step and tls cert for https into)  
  - Ref:  
    - [/HelmWorkShop/traefik-dashboard/IngressRoute-update.yaml](traefik-dashboard/IngressRoute-update.yaml)
  ```
  kubectl apply -f /vagrant/HelmWorkShop/traefik-dashboard/IngressRoute-update.yaml
  ```

- Update traefik helmchart config (for https redirect)  
  - Ref: 
    - [Enable automatics HTTPS redirection](https://www.padok.fr/en/blog/traefik-kubernetes-certmanager#enable)
    - [Traefik HTTP to HTTPS global redirection](https://www.leonpahole.com/2020/05/traefik-basic-setup.html)
    - [/HelmWorkShop/traefik-config/traefik-config-update.yaml](traefik-config/traefik-config-update.yaml)

  ```Bash
  sudo cp /vagrant/HelmWorkShop/traefik-config/traefik-config-update.yaml \
    /var/lib/rancher/k3s/server/manifests/traefik-config.yaml
  ```

## Install Kubernetes Dashboard
<!-- - Create name space
  ```
  kubectl create namespace kube-dashboard
  ``` -->
- Add kubernete-dashboard repo
  ```
  helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
  ```
- Create k8s dashboard self sign cert
  - Ref: 
    - [HelmWorkShop/cert-manager/k8sdashboard-cert-self.yaml](cert-manager/k8sdashboard-cert-self.yaml)
  ```
  kubectl apply -f /vagrant/HelmWorkShop/cert-manager/k8sdashboard-cert-self.yaml
  ```
<!-- openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -keyout ./tls.key -out ./tls.crt -subj "/CN=dashboard.lab" -->
- Istall k8s dashboard under namespace "kube-dashboard" by helm  
  - Ref: 
    - [How to create a namespace if it doesn't exists from HELM templates](https://stackoverflow.com/a/65751410/10833894)
    - [dashboard的chart包配置](https://lemonlzy.cn/2020/10/14/Helm%E9%83%A8%E7%BD%B2Dashboard-UI/#2-2-dashboard%E7%9A%84chart%E5%8C%85%E9%85%8D%E7%BD%AE)
    - [HelmWorkShop/k8s-dashboard/values-new.yaml](k8s-dashboard/values-new.yaml)
  ```
  helm install k8s-dashboard kubernetes-dashboard/kubernetes-dashboard \
    -f /vagrant/HelmWorkShop/k8s-dashboard/values-new.yaml \
    --namespace kube-dashboard --create-namespace --wait
  ```
- Or update the values
  ```
  helm upgrade k8s-dashboard kubernetes-dashboard/kubernetes-dashboard \
    -f /vagrant/HelmWorkShop/k8s-dashboard/values-new.yaml \
    --namespace kube-dashboard
  ```

- Update traefik helmchart config (to disable TLS verification in Traefik by setting the "insecureSkipVerify" setting to "true".)  
  - Ref:  
    - [Kubernetes dashboard through Ingress](https://stackoverflow.com/questions/52312464/kubernetes-dashboard-through-ingress)
    - [Internal Server Error with Traefik HTTPS backend on port 443](https://stackoverflow.com/questions/49412376/internal-server-error-with-traefik-https-backend-on-port-443)
    - [For Traefik Ingress Controller in k3s disable TLS Verification](https://stackoverflow.com/questions/59798395/for-traefik-ingress-controller-in-k3s-disable-tls-verification)
    - [Updating Traefik Ingress Configuration](https://github.com/k3s-io/k3s/issues/1313#issuecomment-918113786)
    - [/HelmWorkShop/traefik-config/traefik-config-update2.yaml](traefik-config/traefik-config-update2.yaml)
  ```
  sudo cp /vagrant/HelmWorkShop/traefik-config/traefik-config-update2.yaml \
    /var/lib/rancher/k3s/server/manifests/traefik-config.yaml
  ```

- Get service account token
  ```
  kubectl -n kube-dashboard describe secret $(kubectl -n kube-dashboard get secret | grep k8s-dashboard | awk '{print $1}')
  ```

## Install Rancher
- Add rancher helm repo  
  ```
  helm repo add rancher-stable https://releases.rancher.com/server-charts/stable
  ```
- Install Rancher with Helm and rancher-generated cert
  ```
  helm install rancher rancher-stable/rancher \
    --namespace cattle-system --create-namespace --wait \
    --set hostname=rancher.lab \
    --set replicas=1
  ```
- Verify that the Rancher Server is Successfully Deployed
  ```
  kubectl -n cattle-system rollout status deploy/rancher
  kubectl get pods --namespace cattle-system
  ```

## Install pihole
- Add mojo2600 helm repo
  ```
  helm repo add mojo2600 https://mojo2600.github.io/pihole-kubernetes/
  helm install pihole mojo2600/pihole -f /vagrant/HelmWorkShop/pihole/values.yaml
  ```


## Install Longhorn
- Add longhorn helm repo
  ```
  helm repo add longhorn https://charts.longhorn.io
  ```
 
- Install pre-request package  
  Ref:
  - [Installation Requirements](https://longhorn.io/docs/latest/deploy/install/#installation-requirements)  
  - [AlpineLinux 3.8: Install open-iscsi for iSCSI initiator](https://www.hiroom2.com/2018/08/29/alpinelinux-3-8-open-iscsi-en/)
  ```
  sudo apk add bash curl findmnt blkid util-linux open-iscsi nfs-utils
  sudo rc-update add iscsid
  sudo rc-service iscsid start
  ```

- Prepare mount root parition script  
  Ref:  
  - [Rancher 2: Kubernetes cluster provisioning fails with error response / is not a shared mount](https://www.claudiokuenzler.com/blog/955/rancher2-kubernetes-cluster-provisioning-fails-error-response-not-a-shared-mount)
  ```
  sudo sh -c "cat >/etc/local.d/make-shared.start" <<EOF
  #!/bin/ash
  mount --make-shared /
  exit
  EOF
  ```

- Let the script run at startup (alpine linux / openrc)  
  Ref: 
  - [Alpine Linux 常用命令](https://blog.csdn.net/ctwy291314/article/details/104634667)
  - [How to run script at startup](https://lists.alpinelinux.org/~alpine/devel/%3CCAF-%2BOzABh_NPrTZ2oMFUKrsYmSE5obOadKTAth1HU5_OEZUxPQ%40mail.gmail.com%3E)
  - [How to enable and start services on Alpine Linux](https://www.cyberciti.biz/faq/how-to-enable-and-start-services-on-alpine-linux/)
  ```
  sudo chmod +x /etc/local.d/make-shared.start
  sudo rc-update add local boot
  sudo rc-service local start
  ```

<!-- kubectl create namespace longhorn-system -->
- Install Longhorn under namespace "longhorn-system"  
  Ref:
  - [Install with Helm](https://longhorn.io/docs/1.2.2/deploy/install/install-with-helm/)
  ```
  helm install longhorn longhorn/longhorn \
    -f /vagrant/HelmWorkShop/longhorn/values.yaml \
    --namespace longhorn-system --create-namespace --wait
  ```
- Have a check
  ```
  kubectl get pods --namespace longhorn-system
  kubectl describe pod longhorn-manager-c8vmh --namespace longhorn-system
  ```

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