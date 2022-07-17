sh $(dirname "$0")/../cert-manager/Set-CAKeyPair.sh
echo "---"
sh $(dirname "$0")/../dex/Set-RBACUserName.sh
echo "---"
sh $(dirname "$0")/../coreDNS/Set-IPAddress.sh
echo "---"
sh $(dirname "$0")/../loginapp/Set-CACert.sh
echo "---"
sh $(dirname "$0")/../longhorn/Set-MountShare.sh
