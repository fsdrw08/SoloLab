yq -i e '.config.clusters[0].certificate-authority = "'"$(sudo cat /var/lib/rancher/k3s/server/tls/server-ca.crt)"'"' \
    /var/vagrant/HelmWorkShop/loginapp/values.yaml \
    && cat /var/vagrant/HelmWorkShop/loginapp/values.yaml