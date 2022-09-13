# sudo sed -i -e "s/tls.crt:*/tls.crt: $(sudo cat /var/lib/rancher/k3s/server/tls/server-ca.crt | base64 -w0)/" \
#   -e "s/tls.key:*/tls.key: $(sudo cat /var/lib/rancher/k3s/server/tls/server-ca.key | base64 -w0)/" \
#   /var/vagrant/HelmWorkShop/cert-manager/ca-issuer/ca-key-pair.yaml \
#   && cat /var/vagrant/HelmWorkShop/cert-manager/ca-issuer/ca-key-pair.yaml

# yq -i e '[0].data."tls.crt" = "'"$(sudo cat /var/lib/rancher/k3s/server/tls/server-ca.crt | base64 -w0)"'" | 
#     [0].data."tls.key" = "'"$(sudo cat /var/lib/rancher/k3s/server/tls/server-ca.key | base64 -w0)"'"' \
#     /var/vagrant/HelmWorkShop/cert-manager/ca-issuer/ca-key-pair.yaml \
#     && cat /var/vagrant/HelmWorkShop/cert-manager/ca-issuer/ca-key-pair.yaml

# yq -i e '(select(.data."tls.crt") | .data."tls.crt") = "'"$(sudo cat /var/lib/rancher/k3s/server/tls/server-ca.crt | base64 -w0)"'"' \
# https://github.com/mikefarah/yq/discussions/816#discussioncomment-743333
yq -i e '(select(.data."tls.crt") | .data."tls.crt") = "'"$(sudo cat /var/lib/rancher/k3s/server/tls/server-ca.crt | base64 -w0)"'" |
(select(.data."tls.key") | .data."tls.key") = "'"$(sudo cat /var/lib/rancher/k3s/server/tls/server-ca.key | base64 -w0)"'"' \
    $(dirname "$0")/ca-issuer/ca-key-pair.yaml \
    && cat $(dirname "$0")/ca-issuer/ca-key-pair.yaml

