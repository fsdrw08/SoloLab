### Deploy CoreDNS in VyOS
CoreDNS act as a dns forwarder, forward dns query to different dns server.
And also a auth dns server, resolve some dns records which service deploy before powerdns
e.g.:  
forward *.consul. dns query to consul dns server (-> day1 -> day2).  
forward *.sololab. dns query to powerdns server (in vyos container).
```powershell
$repoDir=git rev-parse --show-toplevel
$childPath="TerraformWorkShop/VyOS/Container-CoreDNS"
Set-Location -Path (Join-Path -Path $repoDir -ChildPath $childPath)
sudo pwsh.exe -c "terraform init -upgrade";
terraform apply -auto-approve
```
in case of vyos vm recreate, need to clean up some tfstates which related to vyos os config
```powershell
terraform state list
$tfstates=@(
    "vyos_config_block_tree.dns_forwarding",
    "vyos_config_block_tree.reverse_proxy[`"l4_backend`"]",
    "vyos_config_block_tree.reverse_proxy[`"l4_backend_metrics`"]",
    "vyos_config_block_tree.reverse_proxy[`"l4_frontend`"]",
    "vyos_config_block_tree.reverse_proxy[`"l4_frontend_metrics`"]",
    "vyos_config_block_tree.reverse_proxy[`"l7_backend_metrics`"]",
    "vyos_config_block_tree.reverse_proxy[`"l7_frontend_metrics`"]",
    "module.vyos_container.null_resource.load_image[`"coredns`"]",
    "module.vyos_container.vyos_config_block_tree.container_workload[`"coredns`"]"
)
foreach ($tfstate in $tfstates) {
    terraform state rm $tfstate
}