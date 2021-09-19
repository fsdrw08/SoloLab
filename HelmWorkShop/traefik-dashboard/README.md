# according to traefik's installation guide (https://doc.traefik.io/traefik/getting-started/install-traefik/#exposing-the-traefik-dashboard)
kubectl apply -f /vagrant/HelmWorkShop/traefik-dashboard/IngressRoute.yaml

# https://www.padok.fr/en/blog/traefik-kubernetes-certmanager?utm_source=pocket_mylist
kubectl apply -f /vagrant/HelmWorkShop/traefik-dashboard/auth.yaml