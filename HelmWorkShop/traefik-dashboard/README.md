create svc and ing for traefik dashboard
- ref:
  - [Expose traefik dashboard](https://k3s.rocks/traefik-dashboard/)
  - [Traefik Proxy 2.x and Kubernetes 101](https://traefik.io/blog/traefik-proxy-kubernetes-101/)

```
kubectl apply -f /vagrant/HelmWorkShop/traefik-dashboard/traefik-dashboard-ingress.yaml
kubectl apply -f /vagrant/HelmWorkShop/traefik-dashboard/traefik-dashboard-service.yaml
```