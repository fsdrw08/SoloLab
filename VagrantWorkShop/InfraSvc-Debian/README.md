1. run below command to create VM by vagrant, according to the process, it will boot up the alpine linux vm, then download and install k3s
```
vagrant up
```
2. Install k3s
- use powershell
   ```powershell
   $SVRHOST="InfSvc-Debian"
   $TLSSAN="infra.sololab"
   # https://rancher.com/docs/k3s/latest/en/installation/install-options/server-config/#kubernetes-components
   $extraArgs='--disable local-storage --disable traefik --write-kubeconfig ~/.kube/config --write-kubeconfig-mode 644'
   # $extraArgs='--write-kubeconfig-mode 644 --disable local-storage --write-kubeconfig ~/.kube/config'

   # ssh $SVRHOST "curl -sfL http://rancher-mirror.cnrancher.com/k3s/k3s-install.sh | INSTALL_K3S_MIRROR=cn INSTALL_K3S_EXEC='server --cluster-init --tls-san $($TLSSAN) $($extraArgs)' INSTALL_K3S_CHANNEL='stable' sh - && sudo reboot"
   ssh $SVRHOST "curl -sfL http://rancher-mirror.cnrancher.com/k3s/k3s-install.sh | INSTALL_K3S_MIRROR=cn INSTALL_K3S_EXEC='server --cluster-init --tls-san $($TLSSAN) $($extraArgs)' INSTALL_K3S_CHANNEL='stable' sh - && echo 'export KUBECONFIG=/etc/rancher/k3s/k3s.yaml' >> ~/.bashrc"
 


   $token = ssh $SVR01HOST "sudo cat /var/lib/rancher/k3s/server/token"

   ssh $SVR02HOST "wget -q -O /dev/stdout http://rancher-mirror.cnrancher.com/k3s/k3s-install.sh | INSTALL_K3S_MIRROR=cn K3S_URL='https://$($TLSSAN):6443' K3S_TOKEN=$($token) INSTALL_K3S_CHANNEL='stable' INSTALL_K3S_EXEC='server --server https://$($SVR01HOST):6443' sh -s - $($extraArgs)"

   ssh $SVR03HOST "wget -q -O /dev/stdout http://rancher-mirror.cnrancher.com/k3s/k3s-install.sh | INSTALL_K3S_MIRROR=cn K3S_URL='https://$($SVR01HOST):6443' K3S_TOKEN=$($token) INSTALL_K3S_CHANNEL='stable' INSTALL_K3S_EXEC='server --server https://$($SVR01HOST):6443' sh -s - $($extraArgs)"

   ```
2. run below command to login to the vm
```
vagrant ssh
```
3. watch the k3s init process
```
kubectl get events -A --watch
```