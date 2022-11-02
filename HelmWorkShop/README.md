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

## Install kube-vip for control panel HA
- Before install kube-vip, confirm that the router(vyos in this case) had already configed related bgp peering  

- Install kube-vip from helm
  - Ref:
    - [.\HelmWorkShop\kube-vip\values.yaml](kube-vip/values.yaml)
  ```
  helm repo add kube-vip https://kube-vip.io/helm-charts
  helm install kube-vip kube-vip/kube-vip \
    -f  /vagrant/HelmWorkShop/kube-vip/values.yaml \
    --namespace kube-vip --create-namespace
  ```
  - or upgrade
  ```
  helm upgrade kube-vip kube-vip/kube-vip \
    --namespace kube-vip \
    -f  /vagrant/HelmWorkShop/kube-vip/values.yaml
  ```
  - have a check in router (vyos)
  ```
  show ip bgp
  ```

## Install kube-vip-cloud-provider for service loadbalancer
- Install kube-vip-cloud-provider from helm
  - Ref:
    - [.\HelmWorkShop\kube-vip-cloud-provider\values.yaml](kube-vip-cloud-provider/values.yaml)
  ```
  helm install kube-vip-cloud-provider kube-vip/kube-vip-cloud-provider \
    --namespace kube-vip \
    -f /vagrant/HelmWorkShop/kube-vip-cloud-provider/values.yaml
  ```
- Apply related config map
  - Ref:
    - [.\HelmWorkShop\kube-vip-cloud-provider\CM-kubevip.yaml](kube-vip-cloud-provider/CM-kubevip.yaml) 
    - [statefulset config of env var KUBEVIP_NAMESPACE cannot take effect in the pod](https://github.com/kube-vip/kube-vip-cloud-provider/issues/35)
  ```
  kubectl apply -f /vagrant/HelmWorkShop/kube-vip-cloud-provider/CM-kubevip.yaml -n kube-system
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
  ```shell
  helm install cert-manager jetstack/cert-manager \
    --namespace cert-manager --create-namespace \
    --set installCRDs=true \
    --set replicaCount=3 \
    --set webhook.replicaCount=3 \
    --set cainjector.replicaCount=3

  # or
  helm pull jetstack/cert-manager 
  helm install cert-manager /var/vagrant/HelmWorkShop/charts/Artifacts/cert-manager-v1.8.1.tgz \
    --namespace cert-manager --create-namespace \
    --set installCRDs=true 
  ```
  or update helm chart
  ```
  helm upgrade cert-manager jetstack/cert-manager `
    --namespace cert-manager `
    --set replicaCount=3 `
    --set webhook.replicaCount=3 `
    --set cainjector.replicaCount=3 `
    --reuse-values
  ```

- have a check  
  ```
  kubectl get pods --namespace cert-manager
  ```

- Create self sign issuer (optional)  
  - Ref:  
    - https://crt.the-mori.com/2020-11-20-traefik-v2-letsencrypt-cert-manager-raspberry-pi-4-kubernetes  
    - [Use Cert-manager to manage certificates in your cluster](https://www.padok.fr/en/blog/traefik-kubernetes-certmanager#use)  
    - [/HelmWorkShop/cert-manager/issuer-selfsigned.yaml](./cert-manager/issuer-selfsigned.yaml)
  ```
  kubectl apply -f /vagrant/HelmWorkShop/cert-manager/issuer-selfsigned.yaml
  ```

- Create k3s ca key pair (there is already a ca key pair secret "k3s-serving" under kube-system namespace, but secret object cannot invoke across namespace https://stackoverflow.com/questions/46297949/sharing-secret-across-namespaces )
  - Ref:
    - [Manipulating text at the command line with sed](https://www.redhat.com/sysadmin/manipulating-text-sed)
    - [Appending to end of a line using 'sed'](https://askubuntu.com/questions/537967/appending-to-end-of-a-line-using-sed)
    - [sed conditionally append to line after matching pattern](https://stackoverflow.com/questions/55633885/sed-conditionally-append-to-line-after-matching-pattern)
    - [sed "$" not acting as end of line character](https://askubuntu.com/questions/1171030/sed-not-acting-as-end-of-line-character)
    - [How to configure my own CA for k3s](https://github.com/k3s-io/k3s/issues/1868#issuecomment-639690634)
    - [Cert-manager CA](https://cert-manager.io/docs/configuration/ca/)
    - [/HelmWorkShop/cert-manager/ca-key-pair.yaml](./cert-manager/ca-key-pair.yaml)
  ```
  # switch to root first
  sudo su
  # prase the key info
  sed -i -e "/tls.crt:/s/$/$(cat /var/lib/rancher/k3s/server/tls/server-ca.crt | base64 -w0)/" \
  -e "/tls.key:/s/$/$(cat /var/lib/rancher/k3s/server/tls/server-ca.key | base64 -w0)/" \
  /var/vagrant/HelmWorkShop/cert-manager/ca-key-pair.yaml
  # or
  sed -i -e "/tls.crt:/s/$/$(cat /var/lib/rancher/k3s/server/tls/server-ca.crt | base64 -w0)/" \
  -e "/tls.key:/s/$/$(cat /var/lib/rancher/k3s/server/tls/server-ca.key | base64 -w0)/" \
  /var/vagrant/HelmWorkShop/cert-manager/extra-raw-values.yaml
  # have a check
  cat /var/vagrant/HelmWorkShop/cert-manager/ca-key-pair.yaml
  cat /var/vagrant/HelmWorkShop/cert-manager/extra-raw-values.yaml
  # apply it
  kubectl apply -f /var/vagrant/HelmWorkShop/cert-manager/ca-key-pair.yaml
  ```

- Create k3s ca cluster issuer
  - Ref: 
    - [issuer-ca.yaml](cert-manager/issuer-ca.yaml)
  ```
  kubectl apply -f /var/vagrant/HelmWorkShop/cert-manager/issuer-ca.yaml
  ```

- Create ca sign tls cert (infra.sololab) in cert-manager namespace
  - Ref:
    - [tls-sololab-certman.yaml](cert-manager/tls-sololab-certman.yaml)
  ```
  kubectl apply -f /var/vagrant/HelmWorkShop/cert-manager/tls-sololab-certman.yaml
  ```


## Install traefik and config dashboard
- Install traefik by helm
  - Ref:
    - [HelmWorkShop\traefik\values.yaml](traefik/values.yaml)
  ```
  # add traefik helm repo
  helm repo add traefik https://helm.traefik.io/traefik
  # Install traefik
  helm install traefik traefik/traefik \
    --namespace traefik --create-namespace \
    -f /var/vagrant/HelmWorkShop/traefik/values.yaml  \
    --set deployment.replicas=3
  ```
  or upgrade traefik
  ```
  helm upgrade traefik traefik/traefik \
    --namespace traefik \
    -f /var/vagrant/HelmWorkShop/traefik/values.yaml
  ```
  for k3s build-in traefik upgrade
  - Ref: https://phoenixnap.com/kb/helm-install-command#ftoc-heading-3
  ```
  kubectl apply -f /vagrant/HelmWorkShop/traefik/HelmChart-values.yaml
  ```

- Enable traefik dashboard, by defining and applying an IngressRoute CRD, must access with "/" at the end of url!  
  - Ref: 
    - [Exposing the Traefik dashboard](https://doc.traefik.io/traefik/getting-started/install-traefik/#exposing-the-traefik-dashboard)  
    - [/HelmWorkShop/traefik/IngRt-dashboard.yaml](traefik/IngRt-dashboard.yaml)
  ```shell
  kubectl apply -f /var/vagrant/HelmWorkShop/traefik/IngRt-dashboard.yaml

  # kubectl apply -f /vagrant/HelmWorkShop/traefik-dashboard/Svc-traefik-dashboard.yaml

  # kubectl apply -f /vagrant/HelmWorkShop/traefik-dashboard/Ing-traefik-dashboard.yaml
  ```

- Secure access to Traefik using basic auth (add secret and add traefik basic auth middleware point to that secret)  
  - Ref: 
    - [How to configure Traefik on Kubernetes with Cert-manager?](https://www.padok.fr/en/blog/traefik-kubernetes-certmanager?utm_source=pocket_mylist)  
    - [/HelmWorkShop/traefik/MW-basicauth.yaml](traefik/MW-basicauth.yaml)
  ```
  kubectl apply -f /var/vagrant/HelmWorkShop/traefik/MW-basicauth.yaml
  # or
  kubectl apply -f .\HelmWorkShop\traefik\basicAuth.yaml
  ```

- (no need, already config in values.yaml)Add traefik providers.kubernetesingress.ingressclass  
  - Ref:  
    - [Customizing Packaged Components with HelmChartConfig](https://rancher.com/docs/k3s/latest/en/helm/#customizing-packaged-components-with-helmchartconfig)
    - [traefik ingressClass](https://doc.traefik.io/traefik/providers/kubernetes-ingress/#ingressclass)  
    - [/HelmWorkShop/traefik-config/traefik-config.yaml](traefik-config/traefik-config.yaml)
  ```
  sudo cp /vagrant/HelmWorkShop/traefik-config/traefik-config.yaml \
    /var/lib/rancher/k3s/server/manifests/traefik-config.yaml
  ```

- Issue infra.sololab tls cert in traefik namespace (by cert-manager ca issuer)  
  - Ref:
    - [/HelmWorkShop/cert-manager/tls-infra.sololab-traefik.yaml](cert-manager/tls-infra.sololab-traefik.yaml)
  ```
  kubectl apply -f /var/vagrant/HelmWorkShop/cert-manager/tls-infra.sololab-traefik.yaml
  ```

- Update traefik ingressroute (with the traefik auth middleware create in previous step and tls cert for https into)  
  - Ref:  
    - [/HelmWorkShop/traefik/IngRt-dashboardUpdate.yaml](traefik/IngRt-dashboardUpdate.yaml)
  ```
  kubectl apply -f /var/vagrant/HelmWorkShop/traefik/IngRt-dashboardUpdate.yaml
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

- Add traefik stripperfix middleware
  - Ref:
    - [/HelmWorkShop/traefik/MW-stripPrefixRegex.yaml](traefik/MW-stripPrefixRegex.yaml)
  ```
  kubectl apply -f /var/vagrant/HelmWorkShop/traefik/MW-stripPrefixRegex.yaml
  ```

## Install and config dex
- Add dex helm repo and update helm chart  
  ```
  helm repo add dex https://charts.dexidp.io
  helm repo update
  ```
- (no need? this step prepare for next step) Create dex namespace
  ```
  kubectl create namespace dex
  ```

- (no need? use tls cert above instead) Create self sign tls cert for dex 
  - Ref:
    - [dex-cert-self.yaml](./cert-manager/dex-cert-self.yaml)
  ```
  kubectl apply -f /vagrant/HelmWorkShop/cert-manager/dex-cert-self.yaml
  ```

- Install dex via Helm chart (include self sign cert create, namespace create)  
  - Ref:
    - [Setting secrets for Dex in Jenkins-X and Kubernetes](https://blog.lysender.com/2021/09/setting-secrets-for-dex-in-jenkins-x-and-kubernetes/)
    - [dex/values.yaml](dex/values.yaml)
  ```
  helm install dex dex/dex \
    --namespace dex --create-namespace \
    --values /var/vagrant/HelmWorkShop/dex/values.yaml \
    --set replicaCount=3
  ```
  - Or update the values
  ```
  helm upgrade dex dex/dex \
    --namespace dex \
    -f /vagrant/HelmWorkShop/dex/values.yaml
  # or
  helm upgrade dex dex/dex `
    --namespace dex `
    --set replicaCount=3 --reuse-values
  ```
  - Or uninstall the dex helm chart and delete dex namespace, then recreate again
  ```
  helm uninstall dex -n dex
  kubectl delete namespace dex
  ```

- After install dex, check will https://infra.sololab/dex/.well-known/openid-configuration

- (no need? use ingress annotation to create ingress instead) Add ingress route for dex
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
    - [yq - add a multiline string](https://stackoverflow.com/questions/57761285/yq-add-a-multiline-string)
  
  - Config loginapp value, add certificate-authority data
  ```
  yq -i e '.config.clusters[0].certificate-authority = "'"$(sudo cat /var/lib/rancher/k3s/server/tls/server-ca.crt)"'"' /var/vagrant/HelmWorkShop/loginapp/values.yaml
  ```

  - add helm repo and install loginapp
    - Ref:
      - [./loginapp/values.yaml](loginapp/values.yaml)
  ```
  helm repo add fydrah-stable https://charts.fydrah.com
  helm repo update
  # update cert in values before apply it
  yq -i e '.config.clusters[0].certificate-authority = "'"$(sudo cat /var/lib/rancher/k3s/server/tls/server-ca.crt)"'"' /var/vagrant/HelmWorkShop/loginapp/values.yaml
  # helm install
  helm install loginapp fydrah-stable/loginapp \
    --namespace dex \
    --values /var/vagrant/HelmWorkShop/loginapp/values.yaml \
    --set replicas=3
  ```
  or upgrade 
  - ref: 
    - [Understand helm upgrade flags — reset-values & reuse-values](https://medium.com/@kcatstack/understand-helm-upgrade-flags-reset-values-reuse-values-6e58ac8f127e)
  ```
  # update cert in values before apply it
  yq -i e '.config.clusters[0].certificate-authority = "'"$(sudo cat /var/lib/rancher/k3s/server/tls/server-ca.crt)"'"' /vagrant/HelmWorkShop/loginapp/values.yaml
  # helm upgrade
  helm upgrade loginapp fydrah-stable/loginapp \
  --namespace dex \
  --values /vagrant/HelmWorkShop/loginapp/values.yaml 
  # or 
  helm upgrade loginapp fydrah-stable/loginapp \
  --namespace dex \
  --set replicas=3 --reuse-values 
  ```
- add coreDNS A record of issuer fqdn, "infra.sololab" in this case
  - Ref: [.\coreDNS\CM-coredns-custom.yaml](coreDNS/CM-coredns-custom.yaml)
  ```
  kubectl apply -f /var/vagrant/HelmWorkShop/coreDNS/CM-coredns-custom.yaml
  ```

- add rbac for dex local staticPasswords account
  - Ref:
    - [.\HelmWorkShop\dex\RBAC.yaml](dex/RBAC.yaml)
  ```
  kubectl apply -f /var/vagrant/HelmWorkShop/dex/RBAC.yaml
  ```

- Modify api server arg config to make dex as oidc provider  
  - Ref:
    - [K3s customized flags](https://rancher.com/docs/k3s/latest/en/installation/install-options/server-config/#customized-flags)
    - [How to Secure Your Kubernetes Cluster with OpenID Connect  and RBAC](https://developer.okta.com/blog/2021/11/08/k8s-api-server-oidc#k3d)
    - [Set the time zone of your Kubernetes Pod together](https://qiita.com/ussvgr/items/0190bab3cc7d16c0116c) 
    - [How to Secure Your Kubernetes Cluster with OpenID Connect and RBAC](https://developer.okta.com/blog/2021/11/08/k8s-api-server-oidc#kubeadm)
  - add following arg in /etc/init.d/k3s of all nodes(for k3s in apline linux):  `sudo vi /etc/init.d/k3s`  
  ```
  '--kube-apiserver-arg' \
  'oidc-issuer-url=https://infra.sololab/dex' \
  '--kube-apiserver-arg' \
  'oidc-client-id=kubernetes' \
  '--kube-apiserver-arg' \
  'oidc-ca-file=/var/lib/rancher/k3s/server/tls/server-ca.crt' \
  '--kube-apiserver-arg' \
  'oidc-username-claim=email' \
  '--kube-apiserver-arg' \
  'oidc-groups-claim=groups' \
  ```
  then restart the k3s service by
  `sudo /etc/init.d/k3s restart`
  
  - or add above arg in `/etc/systemd/system/k3s.service` of all nodes (for systemd managed linux, e.g. debian,rhel,sle)
   
- ???unset kubectl config
  - Ref: 
    - [Kubernetes: How do I delete clusters and contexts from kubectl config?](https://stackoverflow.com/questions/37016546/kubernetes-how-do-i-delete-clusters-and-contexts-from-kubectl-config)
  ```
  kubectl config unset users.gke_project_zone_name
  kubectl config unset contexts.aws_cluster1-kubernetes
  kubectl config unset clusters.foobar-baz
  ```

- login to https://infra.sololab/sub-loginapp/ and set with new config, put server CA cert under ~\.kube\sololab.crt, config kubectl:
  ```
  kubectl config set-cluster sololab --certificate-authority=~\.kube\sololab.crt --server=https://solo.lab:6443 --insecure-skip-tls-verify=false --embed-certs
  ```

- to switch kubectl context
  - ref: 
    - [Kubectl List and Switch Context](https://linuxhint.com/kubectl-list-switch-context/)
  ```
  # list context
  kubectl config get-contexts

  # switch context (xxx means the name of the context)
  kubectl config set-context xxx
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
- (no need, use ingress annotation to create cert in helm values)Create k8s dashboard self sign cert
  - Ref: 
    - [HelmWorkShop/cert-manager/k8sdashboard-cert-self.yaml](cert-manager/k8sdashboard-cert-self.yaml)
  ```
  kubectl apply -f /vagrant/HelmWorkShop/cert-manager/k8sdashboard-cert-self.yaml
  ```
<!-- openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -keyout ./tls.key -out ./tls.crt -subj "/CN=dashboard.lab" -->
- Isntall k8s dashboard under namespace "kube-dashboard" by helm  
  - Ref: 
    - [How to create a namespace if it doesn't exists from HELM templates](https://stackoverflow.com/a/65751410/10833894)
    - [dashboard的chart包配置](https://lemonlzy.cn/2020/10/14/Helm%E9%83%A8%E7%BD%B2Dashboard-UI/#2-2-dashboard%E7%9A%84chart%E5%8C%85%E9%85%8D%E7%BD%AE)
    - [HelmWorkShop/kube-dashboard/values.yaml](kube-dashboard/values.yaml)
  ```
  helm install kube-dashboard kubernetes-dashboard/kubernetes-dashboard \
    --namespace kube-dashboard --create-namespace \
    -f /var/vagrant/HelmWorkShop/kube-dashboard/values.yaml \
    --set replicaCount=3
  #or
  helm install kube-dashboard kubernetes-dashboard/kubernetes-dashboard `
    -f .\HelmWorkShop\kube-dashboard\values.yaml `
    --namespace kube-dashboard --create-namespace --wait
  ```

- Then visit [infra.sololab/sub-k8sdashboard/](https://infra.sololab/sub-k8sdashboard/) will found that `Internal Server Error`, check logs in kubernetes dashboard
  ```
  kubectl logs <pod name of kubernetes-dashboard> kubernetes-dashboard -n kube-dashboard
  ```
  found that there is a error  
  ```
  http: TLS handshake error from 10.42.0.27:58142: remote error: tls: bad certificate
  ```
  Which means traefik cannot pass http request package to kubernetes dashboard because traefik did not trust kubernetes dashboard's auto-gen cert, we have to bypass cert verify in traefik side, apply a traefik CRD object `ServersTransport`
  - Ref:
    - [traefik2-configure-dashboard.md](https://github.com/zeromake/zeromake.github.io/blob/9bef67eec4087c88491046880e88a01461d6349b/content/post/traefik2-configure-dashboard.md)
    - [.\kube-dashboard\ST-insecureSkipVerify.yaml](kube-dashboard/ST-insecureSkipVerify.yaml)
  ```
  kubectl apply -f /var/vagrant/HelmWorkShop/kube-dashboard/ST-insecureSkipVerify.yaml
  ```

- Update the helm chart values (add service annotations)
  - Ref:
    - [Kubernetes dashboard through Ingress](https://stackoverflow.com/questions/52312464/kubernetes-dashboard-through-ingress)
    - [Serverstransport not working with kubernetes ingress](https://community.traefik.io/t/serverstransport-not-working-with-kubernetes-ingress/12211)
    - [kustomization.yaml](https://github.com/jtcressy/homelab/blob/11b9e43a8cb3e5aed3075049392f155440b095ad/nested-clusters/clusters/edge/kustomization.yaml#L46)
    - [.\kube-dashboard\values-update.yaml](kube-dashboard/values-update.yaml)
  ```
  helm upgrade kube-dashboard kubernetes-dashboard/kubernetes-dashboard \
    --namespace kube-dashboard \
    -f /var/vagrant/HelmWorkShop/kube-dashboard/values-update.yaml
  ```
  
- Or update traefik helmchart config (to disable TLS verification in Traefik(globally) by setting the "insecureSkipVerify" setting to "true".)  
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
  kubectl -n kube-dashboard describe secret $(kubectl -n kube-dashboard get secret | grep kube-dashboard | awk '{print $1}')
  ```

## Install smb csi driver
- Install helm chart
  - ref: https://github.com/kubernetes-csi/csi-driver-smb/tree/master/charts
  ```
  helm repo add csi-driver-smb https://raw.githubusercontent.com/kubernetes-csi/csi-driver-smb/master/charts
  helm install csi-driver-smb csi-driver-smb/csi-driver-smb --namespace kube-system 
  ```
- Create and assign permission to smb share from windows
  ```powershell
  $smbPath="C:\Users\Public\Documents\smb"
  $smbShareName="smb"
  $user="root"
  New-Item -Type Directory -Path $smbPath
  New-SmbShare -Name $smbShareName -Path $smbPath -FullAccess $user

  # Grant user Modify Permission to the smb share
  # ref: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.security/set-acl?view=powershell-7.2#example-5-grant-administrators-full-control-of-the-file
  $smbAcl = Get-Acl -Path $smbPath
  $IdentityReference = $user
  $FileSystemRights = "Modify, Synchronize"
  $AccessControlType = "Allow"
  # Create new rule
  $fileSystemAccessRuleArgumentList = $IdentityReference, $FileSystemRights, $AccessControlType
  $fileSystemAccessRule = New-Object -TypeName System.Security.AccessControl.FileSystemAccessRule -ArgumentList  $fileSystemAccessRuleArgumentList
  # Apply new rule
  $smbAcl.SetAccessRule($fileSystemAccessRule)
  Set-Acl -Path $smbPath -AclObject $smbAcl
  (Get-Acl -Path  $smbPath).Access | ft
  ```  
- Create credential secret for smb
  - ref: https://github.com/kubernetes-csi/csi-driver-smb/blob/master/deploy/example/e2e_usage.md#prerequisite
  ```
  kubectl create secret generic smbcreds --from-literal username=root --from-literal password="root" -n kube-system
  ```
- Create storageclass for smb
  - ref: 
    - [Create a storage class](https://github.com/kubernetes-csi/csi-driver-smb/blob/master/deploy/example/e2e_usage.md#1-create-a-storage-class)
    - [storageclass-smb.yaml](https://github.com/kubernetes-csi/csi-driver-smb/blob/master/deploy/example/storageclass-smb.yaml)
    - [smb-csi-dirver/storageclass-smb.yaml](smb-csi-dirver/storageclass-smb.yaml)
  ```
  kubectl apply -f /var/vagrant/HelmWorkShop/smb-csi-dirver/storageclass-smb.yaml
  ```
- Have a test
  ```
  kubectl apply -f /var/vagrant/HelmWorkShop/smb-csi-dirver/statefulset.yaml
  ```
## Install Longhorn
- Perpare the pre-request config
  1. Install pre-request package  
    - Ref:
         - [Installation Requirements](https://longhorn.io/docs/1.2.4/deploy/install/#installation-requirements)  
         - [AlpineLinux 3.8: Install open-iscsi for iSCSI initiator](https://www.hiroom2.com/2018/08/29/alpinelinux-3-8-open-iscsi-en/)
  ```shell
  sudo apk add bash curl findmnt blkid util-linux open-iscsi nfs-utils jq
  # sudo rc-update add iscsid
  # sudo rc-service iscsid start
  ```

  2. Prepare mount root parition script  
    - Ref:  
      - [Rancher 2: Kubernetes cluster provisioning fails with error response / is not a shared mount](https://www.claudiokuenzler.com/blog/955/rancher2-kubernetes-cluster-provisioning-fails-error-response-not-a-shared-mount)
      - [k3s 安装 longhorn 持久存储](https://cloud.tencent.com/developer/article/1982067)
  ```shell
  sudo mount --make-rshared
  if [ -x /etc/init.d/k3s ] && [[ -z $(grep -l "mount --make-rshared" /etc/init.d/k3s) ]] ; then
    sudo sed -i 's#start_pre() {#start_pre() {\n    mount --make-rshared /#' /etc/init.d/k3s
  fi
  cat /etc/init.d/k3s
  # sudo sh -c "cat >/etc/local.d/make-shared.start" <<EOF
  # #!/bin/ash
  # mount --make-shared /
  # exit
  # EOF
  ```

  3.  (no need?) Let the script run at startup (alpine linux / openrc)  
    - Ref: 
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
  - [Longhorn on k3s](https://www.publish0x.com/awesome-self-hosted/longhorn-on-k3s-xwqdjyj)
  - [.\HelmWorkShop\longhorn\values.yaml](longhorn/values.yaml)
  ```
  helm repo add longhorn https://charts.longhorn.io
  helm install longhorn longhorn/longhorn \
    --namespace longhorn-system --create-namespace \
    -f /var/vagrant/HelmWorkShop/longhorn/values.yaml
  ```
- or upgrade
  ```
  helm upgrade longhorn longhorn/longhorn \
    -f /vagrant/HelmWorkShop/longhorn/values.yaml \
    --namespace longhorn-system 
  ```
- Have a check
  ```
  kubectl get pods --namespace longhorn-system
  kubectl describe pod longhorn-manager-c8vmh --namespace longhorn-system
  ```

## Install freeipa
- Install FreeIPA helm chart
  - Ref:
    - [ArtifactHub/Improwised/freeipa](https://artifacthub.io/packages/helm/improwised/freeipa)
  ```
  helm repo add improwised https://improwised.github.io/charts/
  helm install freeipa improwised/freeipa \
    -f /var/vagrant/HelmWorkShop/freeipa/values.yaml \
    --namespace freeipa --create-namespace --wait
  ```

## Install and config powerdns
- Install fsdrw08 PowerDNS helm chart
  ```
  helm repo add fsdrw08 https://fsdrw08.github.io/helm-charts/
  helm install powerdns fsdrw08/powerdns \
    --namespace powerdns --create-namespace \
    -f /var/vagrant/HelmWorkShop/powerdns/values-sololab-smb.yaml
  ```
  
- Config powerdns-admin
  1. create admin user
  2. config powerdns api url, API KEY and PDNS version,
     api url format: `http://<helm release name>.<namespace>:8081/`, e.g. `http://powerdns.powerdns:8081`
  3. create domain and related in-addr domain, or
- Create domain from powerdns cli (should create domain and in-addr domain), and create TSIG key in powerdns pod, for dynamic dns update
  1. get into the pod
      ```powershell
      kubectl.exe -n powerdns exec <powerdns pod> -it -- /bin/sh
      ```
  2. run command
     - ref: 
       - [Setting up PowerDNS](https://docs.powerdns.com/authoritative/dnsupdate.html#setting-up-powerdns)
       - [PowerDNS with DNS-Update](https://github.com/olivermichel/pdns-dnsupdate/blob/195ba37566f5b4c34d8deadd7dd170f6cc5428c2/README.md)
      ```shell
      KEY_NAME="dhcp-key"
      KEY_CONTENT="FrumijkFJtKANXpQ/ast8uZAtEa0/OO/0qwLIjPesqCe2a0WE05v1Ax4NBxP2EZI2+j1cYq/99hbwi3epUldWg=="
      DOMAIN_NAME="sololab"
      REVERT_DOMAIN_NAME="255.168.192.in-addr.arpa"

      pdnsutil create-zone $DOMAIN_NAME
      pdnsutil create-zone $REVERT_DOMAIN_NAME

      pdnsutil generate-tsig-key $KEY_NAME hmac-sha256
      # or
      pdnsutil import-tsig-key $KEY_NAME hmac-sha256 $KEY_CONTENT

      pdnsutil activate-tsig-key $DOMAIN_NAME $KEY_NAME primary
      pdnsutil activate-tsig-key $REVERT_DOMAIN_NAME $KEY_NAME primary

      # specify actual dhcp server ip (192.168.255.1/32 in this case) will make dns update get refuse,
      # seems need to specify the ip according the container network environment
      # pdnsutil add-meta $DOMAIN_NAME ALLOW-DNSUPDATE-FROM 0.0.0.0/0
      # pdnsutil add-meta $DOMAIN_NAME TSIG-ALLOW-DNSUPDATE $KEY_NAME
      pdnsutil set-meta $DOMAIN_NAME ALLOW-DNSUPDATE-FROM 0.0.0.0/0
      pdnsutil set-meta $DOMAIN_NAME TSIG-ALLOW-DNSUPDATE $KEY_NAME

      pdnsutil set-meta $REVERT_DOMAIN_NAME ALLOW-DNSUPDATE-FROM 0.0.0.0/0
      pdnsutil set-meta $REVERT_DOMAIN_NAME TSIG-ALLOW-DNSUPDATE $KEY_NAME
      ```
  3. In order to take effect of dynamic dns update, apply [dynamic-dns-update](../VagrantWorkShop/VyOS-WAN/provisionConfig-DynDnsUpdate.sh)  to vyos in this case
<!-- 
browser visit powerdns-admin.lab (the address which show in ./powerdns-admin/values.yaml .ingress.hosts.host)
create new user account
..
PDNS API URL: http://<the ip address shows in kubectl get services -n powerdns | grep powerdns-webserver>:<the port number shows in >
PDNS API KEY: <the string which show in ./powerdns/values .powerdns.API_KEY>

kubectl describe pods powerdns-postgresql-0 --namespace powerdns

helm install <pgsql-pdnsadmin> bitnami/postgresql -f ./pgsql-pdnsadmin/values.yaml
 -->

## (optional) Install kubeview
- Install kubeview via helm
  - Ref:
    - [.\kubeview\values.yaml](kubeview/values.yaml)
  ```
  helm repo add kubeview https://benc-uk.github.io/kubeview/charts
  helm install kubeview kubeview/kubeview \
    --create-namespace --namespace kubeview \
    --values /vagrant/HelmWorkShop/kubeview/values.yaml
  ```
  or upgrade
  ```
  helm upgrade kubeview kubeview/kubeview \
    --namespace kubeview \
    --values /vagrant/HelmWorkShop/kubeview/values.yaml
  ```
## Install open ldap
- Install helm-openldap helm repo
  ```powershell
  # config proxy for helm
  # https://github.com/helm/helm/issues/9576
  $env:HTTP_PROXY="127.0.0.1:7890"
  $env:HTTPS_PROXY="127.0.0.1:7890"

  helm repo add helm-openldap https://jp-gouin.github.io/helm-openldap/

  helm install openldap helm-openldap/openldap-stack-ha `
    --create-namespace `
    --namespace openldap `
    --values .\HelmWorkShop\helm-openldap\values.yaml

  # or
  helm upgrade openldap helm-openldap/openldap-stack-ha `
    --namespace openldap `
    --values .\HelmWorkShop\helm-openldap\values.yaml
  ```
- Login to https://login
## Install Harbor
- Add harbor helm repo
  ```
  helm repo add harbor https://helm.goharbor.io
  ```
- Install harbor via helm and values.yaml
  ```
  helm install harbor harbor/harbor `
  --values .\HelmWorkShop\harbor\values.yaml `
  --namespace harbor `
  --create-namespace --wait
  ```
- Or upgrade harbor helm values
  ```
  helm upgrade harbor harbor/harbor `
  --values .\HelmWorkShop\harbor\values.yaml `
  --namespace harbor
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
- Install pihole by helm
  - Ref:
    - [.\HelmWorkShop\pihole\values.yaml](pihole/values.yaml)
  ```
  # add helm repo
  helm repo add mojo2600 https://mojo2600.github.io/pihole-kubernetes/
  # install pihole
  helm install pihole mojo2600/pihole \
    --namespace pihole --create-namespace --wait \
    -f /vagrant/HelmWorkShop/pihole/values.yaml
  ```
- or upgrade upgrade
  ```
  helm upgrade pihole mojo2600/pihole \
    --namespace pihole \
    -f /vagrant/HelmWorkShop/pihole/values.yaml
  ```

```
kubectl describe pod -A
kubectl get pods
kubectl logs <podname>
kubectl exec -it <podname> -- /bin/bash
kubectl get deploy -A
```

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