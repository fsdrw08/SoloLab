```
kube-vip manifest daemonset \
    --interface $INTERFACE \
    --vip $VIP \
    --controlplane \
    --services \
    --inCluster \
    --taint \
    --bgp \
    --bgppeers 192.168.0.10:65000::false,192.168.0.11:65000::false
```