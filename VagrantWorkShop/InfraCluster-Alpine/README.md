1. boot up 3 vms
   ```
   vagrant up
   ```
2. Put vagrant private key into `$ENV:USERPROFILE\.ssh\`  
   ```powershell
   $cnUri = "https://gitee.com/mirrors/vagrant/raw/main/keys/vagrant"
   $githubUri = "https://raw.githubusercontent.com/hashicorp/vagrant/main/keys/vagrant"
   Invoke-WebRequest -Uri $cnUri -OutFile "$ENV:USERPROFILE\.ssh\vagrant"
   ```
   
3. use `k3sup` to deploy k3s cluster  
   ref: [Kubernetes K3s Cluster Using K3sup Multi Master](https://blog.internetz.me/posts/kubernetes-k3s-cluster-using-k3sup-multi-master/)
   ```powershell
   $NODE01IP="192.168.255.10"
   $NODE01HOST="InfraCluster-Alpine1"
   $NODE02IP="192.168.255.11"
   $NODE03IP="192.168.255.12"
   k3sup install --ip $NODE01IP --cluster --k3s-extra-args '--write-kubeconfig-mode 644' --user vagrant --ssh-key "$ENV:USERPROFILE\.ssh\vagrant" 
   k3sup join --ip $NODE02IP --server-ip $NODE01IP --server --k3s-extra-args '--write-kubeconfig-mode 644' --user vagrant --ssh-key "$ENV:USERPROFILE\.ssh\vagrant" 
   k3sup join --ip $NODE03IP --server-ip $NODE01IP --server --k3s-extra-args '--write-kubeconfig-mode 644' --user vagrant --ssh-key "$ENV:USERPROFILE\.ssh\vagrant" 
   # or
   k3sup join --ip $NODE02IP --server-host $NODE01HOST --server --k3s-extra-args '--write-kubeconfig-mode 644' --user vagrant --ssh-key "$ENV:USERPROFILE\.ssh\vagrant" 
   k3sup join --ip $NODE03IP --server-host $NODE01HOST --server --k3s-extra-args '--write-kubeconfig-mode 644' --user vagrant --ssh-key "$ENV:USERPROFILE\.ssh\vagrant" 
   ```
4. add KUBECONFIG env var to cluster nodes
   ```powershell
   @"
   k3snode01
   k3snode02
   k3snode03
   "@ -split "`n" | Foreach-Object {
      ssh $_ "cat /home/vagrant/.profile"
      # ssh $_ "echo 'export KUBECONFIG=/etc/rancher/k3s/k3s.yaml' >> /home/vagrant/.profile"
   }
   ```