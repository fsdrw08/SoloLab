# sudo sed -i -e "s/tls.crt:*/tls.crt: $(sudo cat /var/lib/rancher/k3s/server/tls/server-ca.crt | base64 -w0)/" \
#   -e "s/tls.key:*/tls.key: $(sudo cat /var/lib/rancher/k3s/server/tls/server-ca.key | base64 -w0)/" \
#   /var/vagrant/HelmWorkShop/cert-manager/ca-issuer/ca-issuer-manifest.yaml \
#   && cat /var/vagrant/HelmWorkShop/cert-manager/ca-issuer/ca-issuer-manifest.yaml

# yq -i e '[0].data."tls.crt" = "'"$(sudo cat /var/lib/rancher/k3s/server/tls/server-ca.crt | base64 -w0)"'" | 
#     [0].data."tls.key" = "'"$(sudo cat /var/lib/rancher/k3s/server/tls/server-ca.key | base64 -w0)"'"' \
#     /var/vagrant/HelmWorkShop/cert-manager/ca-issuer/ca-issuer-manifest.yaml \
#     && cat /var/vagrant/HelmWorkShop/cert-manager/ca-issuer/ca-issuer-manifest.yaml

# yq -i e '(select(.data."tls.crt") | .data."tls.crt") = "'"$(sudo cat /var/lib/rancher/k3s/server/tls/server-ca.crt | base64 -w0)"'"' \
yq -i e '(select(.data."tls.crt") | .data."tls.crt") = "'"$(sudo cat /var/lib/rancher/k3s/server/tls/server-ca.crt | base64 -w0)"'" |
(select(.data."tls.key") | .data."tls.key") = "'"$(sudo cat /var/lib/rancher/k3s/server/tls/server-ca.key | base64 -w0)"'"' \
    /var/vagrant/HelmWorkShop/cert-manager/ca-issuer/ca-issuer-manifest.yaml \
    && sleep 1 && cat /var/vagrant/HelmWorkShop/cert-manager/ca-issuer/ca-issuer-manifest.yaml

