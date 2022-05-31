### 1. boot up 3 vms
   ```
   vagrant up
   ```
### 2. Put vagrant private key into `$ENV:USERPROFILE\.ssh\`  
   ```powershell
   $giteeUri = "https://gitee.com/mirrors/vagrant/raw/main/keys/vagrant"
   Invoke-WebRequest -Uri $giteeUri -OutFile "$ENV:USERPROFILE\.ssh\vagrant"
   # or
   $githubUri = "https://raw.githubusercontent.com/hashicorp/vagrant/main/keys/vagrant"
   Invoke-WebRequest -Uri $githubUri -OutFile "$ENV:USERPROFILE\.ssh\vagrant"
   ```

## Put hosts file into each host
   ```powershell
   $SVR01HOST="Inf-Alpine01"
   $SVR02HOST="Inf-Alpine02"
   $SVR03HOST="Inf-Alpine03"

   scp .\hosts $SVR01HOST:~/
   scp .\hosts $SVR02HOST:~/
   scp .\hosts $SVR03HOST:~/
   
   ssh $SVR01HOST "sudo -- sh -c -e 'cat hosts >> /etc/hosts'"
   ssh $SVR02HOST "sudo -- sh -c -e 'cat hosts >> /etc/hosts'"
   ssh $SVR03HOST "sudo -- sh -c -e 'cat hosts >> /etc/hosts'"
   ```
### 3. deploy k3s server cluster  
   - use shell
   ```powershell
   $SVR01HOST="Inf-Alpine01"
   $SVR02HOST="Inf-Alpine02"
   $SVR03HOST="Inf-Alpine03"
   $TLSSAN="infra.sololab"
   $extraArgs='--write-kubeconfig-mode 644 --disable servicelb --disable traefik --write-kubeconfig ~/.kube/config'

   ssh $SVR01HOST "wget -q -O /dev/stdout http://rancher-mirror.cnrancher.com/k3s/k3s-install.sh | INSTALL_K3S_MIRROR=cn INSTALL_K3S_EXEC='server --cluster-init --tls-san $($TLSSAN) $($extraArgs)' INSTALL_K3S_CHANNEL='stable' sh -"

   $token = ssh $SVR01HOST "sudo cat /var/lib/rancher/k3s/server/token"

   ssh $SVR02HOST "wget -q -O /dev/stdout http://rancher-mirror.cnrancher.com/k3s/k3s-install.sh | INSTALL_K3S_MIRROR=cn K3S_URL='https://$($TLSSAN):6443' K3S_TOKEN=$($token) INSTALL_K3S_CHANNEL='stable' INSTALL_K3S_EXEC='server --server https://$($SVR01HOST):6443' sh -s - $($extraArgs)"

   ssh $SVR03HOST "wget -q -O /dev/stdout http://rancher-mirror.cnrancher.com/k3s/k3s-install.sh | INSTALL_K3S_MIRROR=cn K3S_URL='https://$($SVR01HOST):6443' K3S_TOKEN=$($token) INSTALL_K3S_CHANNEL='stable' INSTALL_K3S_EXEC='server --server https://$($SVR01HOST):6443' sh -s - $($extraArgs)"

   ```
<!-- 
   - use `k3sup`  
     - ref: 
     - [Kubernetes K3s Cluster Using K3sup Multi Master](https://blog.internetz.me/posts/kubernetes-k3s-cluster-using-k3sup-multi-master/)
   ```powershell
   $SVR01IP="192.168.255.10"
   $SVR02IP="192.168.255.11"
   $SVR03IP="192.168.255.12"
   $extraArgs='--write-kubeconfig-mode 644 --disable traefik'

   k3sup install --ip $SVR01IP --cluster --k3s-extra-args $extraArgs --user vagrant --ssh-key "$ENV:USERPROFILE\.ssh\vagrant" 

   k3sup join --ip $SVR02IP --server-ip $SVR01IP --server --k3s-extra-args $extraArgs --tls-san "solo.lab" --user vagrant --ssh-key "$ENV:USERPROFILE\.ssh\vagrant" 

   k3sup join --ip $SVR03IP --server-ip $SVR01IP --server --k3s-extra-args $extraArgs --user vagrant --ssh-key "$ENV:USERPROFILE\.ssh\vagrant" 

   # or
   $SVR01HOST="Svr-Alpine01"
   $SVR02HOST="Svr-Alpine02"
   $SVR03HOST="Svr-Alpine03"
   $extraArgs='--write-kubeconfig-mode 644 --disable traefik --write-kubeconfig ~/.kube/config'

   k3sup install --host $SVR01HOST --cluster --k3s-extra-args $extraArgs --user vagrant --ssh-key "$ENV:USERPROFILE\.ssh\vagrant" --print-command

   k3sup join --host $SVR02HOST --server-host $SVR01HOST --server --k3s-extra-args $extraArgs --user vagrant --ssh-key "$ENV:USERPROFILE\.ssh\vagrant" --print-command

   k3sup join --host $SVR03HOST --server-host $SVR01HOST --server --k3s-extra-args $extraArgs --user vagrant --ssh-key "$ENV:USERPROFILE\.ssh\vagrant"  --print-command
   ``` -->

<!-- 1. add KUBECONFIG env var to cluster nodes
   ```powershell
   @"
   k3snode01
   k3snode02
   k3snode03
   "@ -split "`n" | Foreach-Object {
      ssh $_ "cat /home/vagrant/.profile"
      # ssh $_ "echo 'export KUBECONFIG=/etc/rancher/k3s/k3s.yaml' >> /home/vagrant/.profile"
   }
   ``` -->