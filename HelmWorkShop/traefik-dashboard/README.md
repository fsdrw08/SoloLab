# according to rancher's document(https://rancher.com/docs/k3s/latest/en/helm/#customizing-packaged-components-with-helmchartconfig), copy traefik-config.yaml to k3s manifest folder
cp /vagrant/HelmWorkShop/traefik-dashboard/traefik-config.yaml /var/lib/rancher/k3s/server/manifests/traefik-config.yaml

# and according to traefik's installation guide (https://doc.traefik.io/traefik/getting-started/install-traefik/#exposing-the-traefik-dashboard)
kubectl apply -f /vagrant/HelmWorkShop/traefik-dashboard/dashboard.yaml